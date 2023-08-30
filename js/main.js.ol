jQuery(document).ready(function($){

   var getPersonalData;
   if($loadedPersonalData){
	getPersonalData = $.Deferred();
	getPersonalData.resolve($loadedPersonalData);
   }else{
	   getPersonalData = $.ajax({
		   beforeSend: function(xhrObj){
				   xhrObj.setRequestHeader("X-Mensajin","buu");
					},
		   type: "POST",
		   url: "json.php",
		   dataType: "json",
		   data: "a=gpdata"})
	}
	getPersonalData.done(function(datos){
		  if(datos.s){
			 var membblock = '<a href="index?page=cuenta">'+datos.nick+'</a> – <a href="#logout" id="user_logout">Salir</a>'
			 $(".login_visitor_link").html(membblock).show("fast")
			 if(datos.must_complete){
				var complete_html = '<div class="templates_error"><p>Completa tus datos para que podamos darte un mejor servicio <a href="?page=completar" class="button">Completar</a></p></div>';
				$("#replaceme").prepend(complete_html);
			 }
		  }
	   })
    
	
	//Manejar parte de Editar Datos.No sé hasta que punto sería conveniente cargarla solo al accesar solo la pag de editar datos.
   getPersonalData.done(function(personalData){
       if(!$('#editarDatos').length == 0 && personalData.s){
          var elm = $("#editarDatos")
		  
          if(personalData.s){
             elm.find(".numero").val(personalData.numero)
             elm.children(".nombre").val(personalData.nick)
             elm.children(".email").val(personalData.email)
             
			 if(personalData.fbaccess)
				elm.find('.fbintegrated').show()
			 if(!personalData.classic)
				elm.find(".classicpass").remove();
			 
			 
			 $("#editaccount").slideDown("fast")
             
			 
             elm.delegate(".pass_n", "focusin", function(){
                $(this).parent().find(".confirm").slideDown("fast")
             })
             
             elm.submit(function(event){
                event.preventDefault()
                
                var   inp_nombre = elm.children(".nombre"),
                      inp_numero = elm.find(".numero"),
                      inp_email = elm.children(".email"),
                      inp_npass = elm.find(".pass_n"),
                      inp_npassc = elm.find(".pass_nc"),
                      inp_opass = elm.find(".pass_o")
				
                var  nombre = inp_nombre.val(),
                     numero = inp_numero.val(),
                     email = inp_email.val(),
                     npass = inp_npass.val(),
                     cnpass = inp_npassc.val(),
                     opass = inp_opass.val()
                
				if(!inp_npass.val()){
					npass = "";
					cnpass="";
					opass="";
				}
				
                var  boo_nombre = jQuery.trim(nombre).length > 0,
                     boo_numero = isNumber(numero),
                     boo_npassm = npass == cnpass,
                     boo_email = validEmail(email)
                
                if(!boo_nombre)
                   triggerError(inp_nombre,"Ingresa un nombre")
                if(!boo_numero)
					triggerError(inp_numero,"Ingresa un número válido")
                if(!boo_npassm)
					triggerError(inp_npass,"Las contraseñas no concuerdan")
                 if(!boo_email)
					triggerError(inp_email,"Ingresa un email correcto") 
                 
                 if(boo_nombre && boo_numero && boo_npassm){
                    var $button = elm.find(".button");
                    showLoadingFor($button);
                    $button.animate({opacity: "0.3"}, "fast")
                    elm.find(".success_in").hide();
					elm.find(".error_in").hide();
                    var update = $.ajax({
                         beforeSend: function(xhrObj){
                                  xhrObj.setRequestHeader("X-Mensajin","buu");
                                   },
                          type: "POST",
                          url: "json.php",
                          dataType: "json",
                          data: "a=mpdata&nombre="+nombre+"&newpass="+npass+"&password="+opass+"&numero="+numero+"&email="+email
						  }).done(function(datos){
                            if(datos.s){
                               killLoadingFor()
                               $button.animate({opacity: "1"}, "fast")
							   flashMessage(elm.find(".success_in"));
                               
                            }else{
								var $err = elm.find(".error_in");
								switch(datos.error){
									case -5: triggerError(inp_opass.focus(),"La contraseña antigua es incorrecta"); $err.text("Contraseña incorrecta"); break;
									case -6: triggerError(inp_email.focus(),"Correo inválido"); $err.text("El correo es inválido"); break;
									case -7: triggerError(inp_email.focus(),"Correo ya está en uso"); $err.text("Alguien más ya está usando este correo"); break;
									case -8: triggerError(inp_nombre.focus(),"Nombre inválido"); $err.text("Nombre inválido"); break;
								}
								flashMessage($err);            
                               killLoadingFor()
                               $button.animate({opacity: "1"}, "fast")
                            }
                         })
                         .fail(function(datos){
                            loading.css("top", "-200px")
                            elm.find(".error_in").addClass("alt").show("fast").delay(100).removeClass("alt", 300).delay(50).addClass("alt", 300)
                            elm.children(".button").animate({opacity: "1"}, "fast")
                         })
					}
             
          })
		  }else{
             elm.html("<h2>Necesitas iniciar sesión</h2><p>Para cambiar tus datos debes iniciar sesión primero.</p>")
             $("#editaccount").slideDown("fast")
          }
		  }
    })
	
     /*<guests: forms/>*/
	function showLoadingFor($el){
		var $loading = $("#ajax-loading"),
		top = parseInt($el.offset().top+($el.outerHeight()-16)/2),
        left = $el.offset().left+$el.outerWidth()+10;
		$loading.css("top",top).css("left",left)
		/*loading.position({
             "my": "left center",
             "at": "right center",
             "of": $el,
             "offset": "5 0"
          })*/
	}
	function killLoadingFor(){
		$("#ajax-loading").css("top", "-2000px")
	}
	function flashMessage($el){
		$el.addClass("alt").show("fast").delay(100).removeClass("alt", 300).delay(50).addClass("alt", 300)
	}

     $("#replaceme").on("click",".lostpass", function(event){
        event.preventDefault()
		$("#lostpass .success").hide();
		removeAllTips();
        if($("#lostpass").hasClass("clicked")){
           $(this).text("¿Olvidaste tu contraseña?")
           $("#lostpass form").slideUp("fast", function(){
              $("#mensajin_login").slideDown("fast")
              $("#lostpass").removeClass("clicked")
           })
        }else{
           $(this).text("Iniciar sesión »")
           $("#mensajin_login").slideUp("fast", function(){
             $("#lostpass").addClass("clicked")
             $("#lostpass form").slideDown("fast") 
           })
        }
     }).on("submit", "#lostpass", function(event){
        event.preventDefault()
		removeAllTips();
        var el = $(this),
        email = el.find(".textbox.email").val(),
        button = el.find(".button")
        
		if(!validEmail(email)){
			triggerError(el.find(".textbox.email"),"Correo inválido")
			return -1;
		}
        button.animate({opacity: "0.3"}, "fast")
        showLoadingFor(button)
        
        var sendReminder = $.ajax({
            beforeSend: function(xhrObj){
                  xhrObj.setRequestHeader("X-Mensajin","buu");
                   },
            type: "POST",
            url: "json.php",
            dataType: "json",
            data: "a=remind&email="+email})
            .done(function(datos){
               if(datos.s){
				  $("#lostpass form").hide();
				  el.find(".error_in").hide();
                  flashMessage($("#lostpass .success"))
				  button.animate({opacity: "1"}, "fast")
               }else{
                  flashMessage(el.find(".error_in").text("Ha habido un error al enviar el correo."))
                  el.find(".button").animate({opacity: "1"}, "fast")
               }
               killLoadingFor()
            })
            .fail(function(datos){
               flashMessage(el.find(".error_in").text("Ha habido un problema con el servidor."))
               el.find(".button").animate({opacity: "1"}, "fast")
            })
     })
     
	 $("#replaceme").on("click", "#showloginme", function(){
		$(this).slideUp("fast", function(){
			$(".mensajin_login_wrap").slideDown("fast")
			})
	 }).on("submit", "#mensajin_login", function(event){
         event.preventDefault()
		var $el = $(this),
		$user = $el.children(".user"),
		user = $user.val(),
		$button = $el.find(".button");
		
		if($.trim(user)){
			var pass = $el.children(".password").val(),
			params = ['a=login', 'user='+user, 'password='+pass],
			query = params.join('&');
			
			$button.animate({opacity: "0.3"}, "fast")
			showLoadingFor($button)
			var login = $.ajax({
				beforeSend: function(xhrObj){xhrObj.setRequestHeader("X-Mensajin","buu");},
				type: "POST",
				url: "json.php",
				dataType: "json",
				data: query
		   }).done(function(datos){
				 if(datos.s){
					window.location = "index.php"
				 }else{
					flashMessage($el.find(".error_in").text("El usario/contraseña es incorrecto."))
					$button.animate({opacity: "1"}, "fast")
					killLoadingFor();
				 }
				})
			.fail(function(datos){
				 $el.find(".error_in").text("No hemos logrado conectarte a Mensajin").show("fast")
				 flashMessage( $el.find(".error_in"))
				 $button.animate({opacity: "1"}, "fast")
				 killLoadingFor();
				})
		}
      })
	  
	  $("#replaceme").on("click", "#fb_login",function(e){
		e.preventDefault();
		var $fbtn = $(this)
		$fbtn.siblings('.error_in').hide()
		$fbtn.removeClass('error').addClass('selected')
		showLoadingFor($fbtn);
		var fbw = window.open("fb.php")
		var code="";
		var timer = setInterval(function() {
				if(fbw.closed) {
					$errbox = $fbtn.siblings('.error_in')
					clearInterval(timer);
					if(!grabPopupHelper){
						$fbtn.addClass('error').removeClass('selected')
						flashMessage($errbox.text('Cerraste la ventana sin confirmar'))
					}else{
						grabPopupHelper.done(function(data){
							if(data.s && !data.error){
								$fbtn.addClass('success').removeClass('selected')
								window.location = "index.php"
							}else{
								switch(data.error){
									case -1: flashMessage($errbox.text('No hemos podido identificarte con Facebook')); break;
									case -22: flashMessage($errbox.text('No hemos podido identificarte con Facebook')); break;
									case -20: $fbtn.addClass('success').removeClass('selected'); $(".integrate_account.fb").slideDown(); break;
									case -21: $fbtn.addClass('success').removeClass('selected'); window.location = "?page=completar";
								}	
							}
						})
					}
					killLoadingFor();
				}
			}, 1000);  
	})
	$("#replaceme").on("submit", "#integrar_cuenta", function(e){
		e.preventDefault();
		var $el = $(this),
		$passInput = $el.find(".password"),
		pass = $passInput.val(),
		$errPlace = $el.find(".error_xhr");
		
		if($.trim(pass)){
			 $.ajax({
             beforeSend: function(xhrObj){xhrObj.setRequestHeader("X-Mensajin","buu");},
             type: "POST",
             dataType: "json",
             url: "json.php",
             data: "a=integrafb&"+"password="+pass})
             .done(function(datos){
                if(datos.s){
                  window.location = "index.php"
                }else{
					var err = datos.error;
					switch(err){
					   case -1:
							flashMessage($errPlace.text("Ha habido un error, porfavor intenta de nuevo."));
							break;
					   case -5:
							flashMessage($errPlace.text("Contraseña incorrecta"));
							triggerError($passInput, "Contraseña errónea"); break;
					}
				}
             })
             .fail(function(){
                flashMessage($errPlace.text("Ha habido un error, porfavor intenta de nuevo."));
             })
		
		}
	})
	
	if($("#completar_datos").length>0){
		var $el = $("#completar_datos");
		getPersonalData.done(function(datp){
			if(datp.s){
				if(datp.birthdate)
					$el.find('.cumple').parent().remove()
				if(datp.numero)
					$el.find('.celular').parent().remove()
				if(datp.location)
					$el.find('.lugar').parent().remove()
					
				if(!$el.find(".textbox").length>0){
					var $parent = $el.parent();
					$parent.siblings("h2").text("Gracias!").siblings("p").text('Ya has terminado de completar tus datos')
					$parent.hide();
				}
			}
		})
	}
	$("#replaceme").on("submit", "#completar_datos", function(e){
		e.preventDefault();
		var $el = $(this),
		$numInp = $el.find('.celular'),
		$locInp = $el.find('.lugar'),
		$birInp = $el.find('.cumple'),
		num = $numInp.val(), loc, bir,
		errors = 0;
		
		if($locInp.length>0){
			loc = $locInp.val()
			if(!$.trim(loc)){
				triggerError($locInp, "Ingresa un lugar");errors++;
			}
		}
		if($birInp.length>0){
			bir = $birInp.val()
			if(!validDate(bir)){
				triggerError($birInp, "Fecha Inválida");errors++;
			}
		}
		if($numInp.length>0){
			if(!$.isNumeric(num)){
				alert("lololol")
				triggerError($numInp, "Número inválido"); errors++;
			}
		}
		
		if(errors!=0)
			return false;
			
		$errPlace = $el.find(".error_in");
		$.ajax({
             beforeSend: function(xhrObj){xhrObj.setRequestHeader("X-Mensajin","buu");},
             type: "POST",
             dataType: "json",
             url: "json.php",
             data: "a=compreg&"+"numero="+num+"&lugar="+loc+"&cumple="+bir})
             .done(function(datos){
                if(datos.s){
                  window.location = "index.php"
                }else{
					var err = datos.error;
					switch(err){
					   case -1:
							flashMessage($errPlace.text("Ha habido un error, porfavor intenta de nuevo."));
							break;
					}
				}
             })
             .fail(function(){
                flashMessage($errPlace.text("Ha habido un error, porfavor intenta de nuevo."));
        })
		/*var $passInput = $el.find(".password"),
		pass = $passInput.val(),
		$errPlace = $el.find(".error_xhr");
		
		if($.trim(pass)){
			 $.ajax({
             beforeSend: function(xhrObj){xhrObj.setRequestHeader("X-Mensajin","buu");},
             type: "POST",
             dataType: "json",
             url: "json.php",
             data: "a=integarfb&"+"password="+pass})
             .done(function(datos){
                if(datos.s){
                  window.location = "index.php"
                }else{
					var err = datos.error;
					switch(err){
					   case -1:
							flashMessage($errPlace.text("Ha habido un error, porfavor intenta de nuevo."));
							break;
					   case -5:
							flashMessage($errPlace.text("Contraseña incorrecta"));
							triggerError($passInput, "Contraseña errónea"); break;
					}
				}
             })
             .fail(function(){
                flashMessage($errPlace.text("Ha habido un error, porfavor intenta de nuevo."));
             })
		}*/
	});
      /*</guests: forms>*/
	  $("header").on("click", "#user_logout", function(event){
         event.preventDefault()

         var signOut = $.ajax({
             beforeSend: function(xhrObj){
                     xhrObj.setRequestHeader("X-Mensajin","buu");
                      },
             type: "POST",
             dataType: "json",
             url: "json.php",
             data: "a=sout"})
             .done(function(datos){
                if(datos.s){
                  window.location = "index.php"
                }else{
					alert("Intenta de nuevo")
				}
             })
             .fail(function(datos){
                alert("Intenta de nuevo")
             })
      })

     /*</members: header>*/

     /*Quick search*/
     var qs = $('input#search_contacts').quicksearch('#contactos li:not(.editingnow)');
	 $(".contact_search form").on("submit", function(event){
		event.preventDefault();
	 })
     /*<Agenda: plantillas>*/
	 
     $.template(
       "agendaContact",
       "<li class='clearfix contact-${id} contact' id='agenda-contact-${id}'><span class='icon sender'>Send</span><h3 title='Enviar Mensaje'><a class='name'>${nombre}</a></h3><span class='phonenm'>${numero}</span><div class='opc'><span class='icon edit'>Edit</span><span class='icon delete'>Delete</span></div></li>"
     );
     $.template(
       "agendaHacerContacto",
       '<form id="hacercontacto-${id}" class="hacercontacto"><div class="input_phone"><span class="icon person">Person</span><input class="textbox nombre" type="text" name="nombre" value="${nombre}" onfocus="if(this.value == \'Nombre...\') { this.value = \'\'; }" onblur="if(this.value==\'\') { this.value=\'Nombre...\'; }" size="14" /></div><div class="input_phone"><span class="icon phone blue">Phone</span><input class="textbox tele" type="text" name="telefono" value="${numero}" onfocus="if(this.value == \'Número...\') { this.value = \'\'; }" onblur="if(this.value==\'\') { this.value=\'Número...\'; }" size="12" maxlength="8"  /></div><span class="button check"><input type="submit" value="Agregar" class="icon tick" /></span><span class="icon cancel"></span></form>'
      );
     /*</Agenda: plantillas>*/

	 
     /*<Agenda: load>*/
     var pedirAgenda;
	if($("#agenda").length>0){
		getPersonalData.done(function(data){
			var $agerror = $("#agenda .error_in ");
			if(data.s){
				 $("#agenda").slideDown()
			
				pedirAgenda  = $.ajax({
				beforeSend: function(xhrObj){xhrObj.setRequestHeader("X-Mensajin","buu");},
				type: "POST",
				url: "json.php",
				dataType: "json",
				data: "a=agenda"})
				.done(function(datos){
				   agendaXHR = datos
				   if(agendaXHR.s){
					  $.tmpl( "agendaContact", agendaXHR.agenda ).appendTo( "#contactos ul" )
					  qs.cache()
					  $("#contactos h3").tipsy({gravity: "w", offset: "3px", trigger: "manual"})
					  setClips()
				   }else{
					  var err = agendaXHR.error
					  switch(err){
						 case -1:
							 flashMessage($agerror.text("Ha ocurrido un error. Porfavor intenta actualizar la página."))
							 break;
						 case -2:
							flashMessage($agerror.text("Debes iniciar sesión para ver tus contactos."))
						}
				   }
				   $("#agenda .loaderind").slideUp();
				})
				.fail(function(err){
				   flashMessage($agerror.text("Ha ocurrido un error. Porfavor intenta actualizar la página."))
				   $("#agenda .loaderind").slideUp();
				})
			}
		})
	}
     /*</Agenda: load>*/
     function setClips(){
        pedirAgenda.done(function(datos){
          if(datos.s){
             //$("#contactos h3").zclip('remove');
             $("#contactos h3").filter(":not('.haszclip')").addClass('haszclip').zclip({
                        path:'js/ZeroClipboard.swf',
                        copy:function(){
                           $(this).tipsy("hide");
                           return $(this).parent().find(".phonenm").text()
                        },
                        afterCopy: function(){
                           var $el = $(this).parent(),
                           $num = $el.find(".phonenm"),
                           empre = empresa($num.text());
                           if(empre!=5 || empre!=4){
                              $el.addClass("clicked");
                              triggerTip($num,"Se ha copiado el número","n");
                              enviarPopUp(empre);
                           }else{
                              triggerTip($num,"Número inválido","n");
                           }
                        }
                  })
              }
        })
     }
     
     $("#enviarMensaje .copy_button").tipsy()
     
     $("#enviarMensaje .copy_button").zclip({
        path: "js/ZeroClipboard.swf",
        copy: function(){
           return $("#enviarMensaje .textbox").val()
        },
        afterCopy: function(){
           $("#enviarMensaje .textbox").attr("title", "Se ha copiado el número")
           $("#enviarMensaje .textbox").tipsy({trigger: "manual"})
           $("#enviarMensaje .textbox").tipsy("show")
           $("#enviarMensaje .textbox").addClass("hasTip")
        }
     })
     
     /*$("#enviarMensaje").delegate(".textbox.hasTip", "focus", function(){
        $(this).tipsy("hide")
     })*/
     
     /*<Agenda: manejar efectos>*/
     $("#contactos h3, #contactos .sender").css("cursor", "pointer")

	 
     $("#contactos").on("mouseenter", "li", function(){
        $(this).addClass("hovered").children(".phonenm, .opc").stop(true,true).show(150)
        $(this).children(".sender").addClass("hover")
     }).on("mouseleave","li", function(){
        $(this).removeClass("hovered").removeClass("clicked").children(".phonenm, .opc").hide()
         
         var wtip = $(this).find(".phonenm.hasTip")
         if(wtip.length > 0){
            wtip.tipsy("hide")
            wtip.removeClass("hasTip")
         }
         
         $(this).children(".sender").removeClass("hover")
         $(this).removeClass("deleteask")
     }).on("mouseenter", "h3", function(){
        $(this).tipsy("show")
     }).on("mouseleave","h3", function(){
        $(this).tipsy("hide")
     })/*.on("mouseleave",".zclip", function(){
        var el= $(this).parent()
        el.addClass("hovered").children(".phonenm, .opc").stop(true,true).show(150)
        el.children(".sender").addClass("hover")
     })*/
     /*</Agenda: manejar efectos>*/

     /*<Agenda: editar contactos>*/
     $("#contactos").on("click", ".edit", function(){
        var elm = $(this).parent().parent(),
        nombre = elm.children("h3").text(),
        id = elm.attr("id").replace("agenda-contact-", ""),
        numero = elm.children(".phonenm").text()
		elm.addClass("editingnow").hide()
		qs.cache();
        var info = [{ "id": id, "nombre": nombre, "numero": numero }];
        $.tmpl( "agendaHacerContacto", info ).insertAfter(elm).wrap("<li class='clearfix contact hovered editing'></li>").find(".nombre").focus();
        
        
     }).on("click", ".delete", function(){
        var elm = $(this).parent().parent(),
		$agerror = $("#agenda .error_in");
        if(elm.hasClass("deleteask")){
           var ide = elm.attr("id").replace("agenda-contact-", "")
           var eliminarContacto = $.ajax({
               beforeSend: function(xhrObj){xhrObj.setRequestHeader("X-Mensajin","buu");},
               type: "POST",
               url: "json.php",
               dataType: "json",
               data: "a=dcon&id="+ide})
               .done(function(datos){
                  if(datos.s){
                      elm.slideUp("fast", function(){
                        elm.remove() 
                        setClips()
                      })
                  }else{
					flashMessage($agerror.text("Tu sesión ha expirado, inicia de nuevo."))
				  }
               })
               .fail(function(datos){
                  flashMessage($agerror.text("Ha ocurrido un error, intenta refrescar la página."))
               })
        }else{
           elm.addClass("deleteask")
        }
     })
     /*.on("click", "h3, .sender", function(){
        var num = $(this).parent().find(".phonenm").text()
		alert(num)
        $(this).parent().addClass("clicked")
        enviarPopUp(empresa(num))
     })*/
     
     /*Tips*/
     
     function validateContact(elm){
		var errors = 0,
		nombInp = elm.find(".nombre"),
        nomb = $.trim(nombInp.val()),
		teleInp = elm.find(".tele"),
		tele = teleInp.val();
		
		if(!nomb){
			triggerError(nombInp,"Ingresa un nombre"); errors++;
		}
		if(!isNumber(tele)){
			triggerError(teleInp,"Ingresa un número válido"); errors++;
		}
         if(errors==0){
            var info =  {"nombre": nomb, "numero": tele }
            return info
         }else{
            return false
         }
         
     }
     
     $("#contactos").delegate("li form", "submit", function(event){
         event.preventDefault()
         var elm = $(this).parent()
         var info = validateContact(elm),
		 $agloader = $("#agenda .loaderind");
         if(info!=false){
            var ide = $(this).attr("id")
            ide = ide.replace("hacercontacto-", "")
			$agloader.slideDown();
            $.ajax({
              beforeSend: function(xhrObj){
                      xhrObj.setRequestHeader("X-Mensajin","buu");
                       },
              type: "POST",
              url: "json.php",
              dataType: "json",
              data: "a=mcon&id="+ide+"&nombre="+info.nombre+"&numero="+info.numero})
              .done(function(datos){
                 if(datos.s){
                    infoN = [
                        { "id": ide, "nombre": info.nombre, "numero": info.numero }
                     ];
                     $("#agenda-contact-"+ide).remove()
                     $.tmpl( "agendaContact", infoN ).insertAfter(elm)
                     elm.remove()
                     $("#contactos h3").tipsy({gravity: "w", offset: 3, trigger: "manual"})
                     setClips()
					 $agloader.slideUp();
                 }else{
					flashMessage($("#agenda .error_in").text("Tu sesión ha expirado, inicia de nuevo."))
				 }
              })
			  .fail(function(datos){
                 $agloader.slideUp();
				 flashMessage($("#agenda .error_in").text("Ha ocurrido un error. Porfavor intenta actualizar la página."))
				 
              })
         }
     }).delegate(".error", "focus", function(){
        $(this).removeClass("error")
        $(this).tipsy("hide")
     }).delegate(".cancel", "click", function(){
        var ide = $(this).parent().attr("id")
        if($("#"+ide).find(".error").length>0){
           $("#"+ide).find(".error").tipsy("hide")
        }
        $("#"+ide).parent().remove()
        ide = ide.replace("hacercontacto-", "agenda-contact-")
        $("#"+ide).show()
     })

     /*Agenda: agregar contacto*/
     var addcontact = [
       { id: "agregarContacto", "nombre": "Nombre...", "numero": "Número..." }
     ];
     $.tmpl( "agendaHacerContacto", addcontact ).appendTo( "#addcontact .contacter" );

     $("#addcontact").on("click", "h3", function(){
        var $el = $(this);
		if($el.hasClass("clicked")){
           $el.removeClass("clicked")
           $("#addcontact .contacter").hide("fast")
        }else{
           $el.addClass("clicked")
           $("#addcontact .contacter").show().find(".nombre").focus()
        }
     })

     $("#hacercontacto-agregarContacto").submit(function(event){
         event.preventDefault()
         var elm = $(this).parent(),
		 $loaderag = $("#agenda .loaderind"),
         info = validateContact(elm),
		 $agerror = $("#agenda .error_in ");
		 
         if(info!=false){   
			$loaderag.slideDown();
            var agregarContacto = $.ajax({
                 beforeSend: function(xhrObj){
                         xhrObj.setRequestHeader("X-Mensajin","buu");
                          },
                 type: "POST",
                 url: "json.php",
                 dataType: "json",
                 data: "a=acon&nombre="+info.nombre+"&numero="+info.numero})
				 .done(function(datos){
                    if(datos.s){
						
                       var infoN = [
                           { "id": datos.id, "nombre": info.nombre, "numero": info.numero }
                        ];
            
                        $.tmpl( "agendaContact", infoN ).appendTo("#contactos ul").hide().slideDown()
                        $("#contactos h3").tipsy({gravity: "w", offset: "3px", trigger: "manual"})
            
                        $("#addcontact .contacter").hide("fast")
                        $("#addcontact h3").removeClass("clicked")
                        
						removeTipsFrom(elm);
                        elm.find(".nombre").val("Nombre")
                        elm.find(".tele").val("Teléfono")
						$loaderag.slideUp();
						setClips();
                    }else{
						flashMessage($agerror.text("Tu sesión ha expirado, inicia de nuevo."));
					}
				})
                 .fail(function(datos){
                    flashMessage($agerror.text("Revisa tu conexión a internet"));
                 })
        }
     }).delegate(".cancel", "click", function(){
        
        $("#addcontact h3").removeClass("clicked")
		removeTipsFrom($("#addcontact .contacter").hide("fast"))
        clicked = !clicked
     })

     $("form").delegate(".error", "focus", function(){
        $(this).removeClass("error")
        $(this).tipsy("hide")
     })

     /*<Enviar Mensaje>*/
     $("#content").delegate("#enviarMensaje","submit", function(event){
        event.preventDefault()
        var comp = $("#enviarMensaje .textbox").val()
        var emp = empresa(comp)
        var numInp = $(this).find(".textbox")
        if(emp==4){
           numInp.addClass("error").attr("title", "Número inválido")
           numInp.tipsy({gravity: "n", trigger: "manual"})
           numInp.tipsy("show")
        }else{
           if(emp==5){
              numInp.addClass("error").attr("title", "Número desconocido")
              numInp.tipsy({gravity: "n", trigger: "manual"})
              numInp.tipsy("show")
           }else{
              enviarPopUp(emp)
           }  
        }
     }).delegate(".operadores a", "click", function(event){
        event.preventDefault()
        comp = $(this).attr("rel")*1
        enviarPopUp(comp)
     })

	 $("#replaceme").on("keyup", "#enviarMensaje .textbox", function(){
		
		var cur_num = $(this).val();
		if(cur_num.length == 8){
			var prove = empresa(cur_num)
			$(".recognized").removeClass("recognized");
			switch(prove){
				case 1: $(".icon.movis").parent().addClass("recognized mov"); break;
				case 2: $(".icon.tigo").parent().addClass("recognized tig"); break;
				case 3: $(".icon.claro").parent().addClass("recognized clar"); break;
			}
		}else
			$(".recognized").removeClass("recognized");
		
	 })
	 
     function enviarPopUp(comp){

        switch(comp){
                case 1:
                    var winpops=window.open("http://www.corporativo.telefonica.com.gt/EnviarSMSGT/faces/EnviarSMS2.jsp","","width=250,height=330,resizable");
                    if(!winpops)
                        alert('Tu bloqueador de popups ha bloqueado la ventana, desactivalo para mensajin.com porfavor!');

                    break;
                case 2:
                    var winpops=window.open("http://200.49.163.92/sms_inter_v22.swf","","width=328,height=482,resizable");
                    if(!winpops)
                        alert('Tu bloqueador de popups ha bloqueado la ventana, desactivalo para mensajin.com porfavor!');
                    break;
                case 3:
                    var winpops=window.open("http://mensajes.claro.com.gt/mensaje_claro.php","","width=223,height=295,resizable");
                    if(!winpops)
                        alert('Tu bloqueador de popups ha bloqueado la ventana, desactivalo para mensajin.com porfavor!');
                    break;
                case 5:
                    $("#enviarMensaje .textbox").addClass("error")
                    break;
                case 4:
                    $("#enviarMensaje .textbox").addClass("error")          
					break;
                }
     }
	 
     $.template(
            "newsNew",
            '<li class="news_li"><div class="news_head"><span class="date">${fecha}</span><h3>${titulo}</h3><span class="author">${autor}</span></div><div class="news_body">${contenido}</div><div class="news_footer"><span class="more handy">Leer más &raquo;</span></div></li>'
          );
     if($("#news_list").length>0){
        $.ajax({
              type: "get",
              url: "news_stream.txt",
              dataType: "json"
			  })
              .done(function(datos){
                 $.tmpl("newsNew", datos.noticias).appendTo("#news_list")
				 $('.news_li').each(function(i){
					var $el = $(this).css('opacity', '0'),
					$txt = $el.find(".news_body"),
					hei = $txt.height();
					$el.hide()
					
					if(hei>100)	{$txt.height(70); $txt.attr('original-height', hei)}
					else{
						$el.find(".more").hide()
					}
					$el.css('opacity', '1').slideDown("fast");
				 })
              })
     }
	 $("#news_list").on("click",".more", function(){
		   var $txt = $(this).parent().parent().find(".news_body");
		   $(this).parent().parent().children(".news_body").animate({height: $txt.attr('original-height')}, "fast")
           $(this).html("&laquo; Leer menos").removeClass("more").addClass("less")
        })
	$("#news_list").on("click",".less", function(){
           $(this).parent().parent().children(".news_body").animate({height: "70px"}, "fast")
           $(this).html("Leer más &raquo;").removeClass("less").addClass("more")
    })
     function isNumber(numo){
        if (/^\d*$/.test(numo)){
           var emp = empresa(numo);
		   
		   return  (emp!=5 && emp!=4)
        }
     }
     
	 /**
	* @param email
	* @return si es correcto o no
	*/
	 function validEmail(email){
		var emailpattern = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
		return emailpattern.test(email)
	 }
	/**
	* @param inputs a validar
	* @return el número de inputs en blanco encontrados
	*/
	function checkBlankInputs($inputs){
		var errors = 0;
		$inputs.each(function(index) {
			var val = $.trim($(this).val())
			if(!val){
				triggerError($(this), "Debes llenar el campo")
				errors++;
			}
		});
		return errors;
	}
	 /**
	* @param date
	* @return si es correcto o no
	*/
	 function validDate(date){
		var dateA = date.split("/");
		if(dateA.length==3){
			var day = dateA[0],
			month = dateA[1]-1,
			year = dateA[2];
			
			source_date = new Date(year,month,day);

			if(year==source_date.getFullYear() && month==source_date.getMonth() && day==source_date.getDate()){
				return true;
			}else{
				return false;
			}
		}
		return false;
	 }
	function triggerError($el, message){
		$el.addClass("error")
		triggerTip($el, message, "sw")
	}
	/**
	* Marca con error un campo
	* @param elemento a marcar con error
	* @param mensaje de error
	*/
	function triggerTip($el, message, orientation){
		$el.addClass("error").attr("title", message)
		$el.tipsy({gravity: orientation, trigger: "manual"})
		$el.tipsy("show")
		$el.addClass("hasTip")
	}
	$("body").on("focus",".hasTip", function(){
        $(this).removeClass("error")
        $(this).tipsy("hide")
     })
	/**
	* Quita todos los tips activos
	*/
	 function removeAllTips(){
		removeTipsFrom($("body"))
	 }
	 /**
	* Quita todos los tips activos
	*/
	 function removeTipsFrom($elm){
		var $tips = $elm.find(".hasTip")
		$tips.each(function(){
			$(this).tipsy("hide")
			$(this).removeClass("hasTip")
			$(this).removeClass("error")
		})
	 }
     function empresa(numo){

         num = numo * 1;

         // Comprobación inicial
         if(num < 30000000 || num >= 60000000)
             return 5;

         // Comcel 
         if(
             ((30000000<= num) && (num <= 30289999)) ||
             ((40000000<= num) && (num <= 40999999)) ||
             ((44760000<= num) && (num <= 46999999)) ||
             ((47730000<= num) && (num <= 48199999)) ||
             ((48220000<= num) && (num <= 50099999)) ||
             ((50300000<= num) && (num <= 50699999)) ||
             ((51500000<= num) && (num <= 52099999)) ||
             ((53000000<= num) && (num <= 53099999)) ||
             ((53140000<= num) && (num <= 53899999)) ||
             ((55200000<= num) && (num <= 55299999)) ||
             ((55500000<= num) && (num <= 55539999)) ||
             ((55800000<= num) && (num <= 55819999)) ||
             ((57000000<= num) && (num <= 57099999)) ||
             ((57190000<= num) && (num <= 57899999)) ||
             ((58000000<= num) && (num <= 58099999)) ||
             ((58190000<= num) && (num <= 58199999)) ||
             ((58800000<= num) && (num <= 59099999)) ||
             ((59180000<= num) && (num <= 59199999)) ||
             ((59900000<= num) && (num <= 59999999)) 

         )
             return 2;

         // Telefónica
         else if(
             ((43000000<= num) && (num <=44759999)) ||
             ((50200000<= num) && (num <=50299999)) ||
             ((50700000<= num) && (num <=51099999)) ||
             ((51400000<= num) && (num <=51499999)) ||
             ((52100000<= num) && (num <=52999999)) ||
             ((53120000<= num) && (num <=53139999)) ||
             ((53900000<= num) && (num <=54099999)) ||
             ((55000000<= num) && (num <=55099999)) ||
             ((55180000<= num) && (num <=55199999)) ||
             ((55400000<= num) && (num <=55429999)) ||
             ((55450000<= num) && (num <=55499999)) ||
             ((56000000<= num) && (num <=56099999)) ||
             ((56400000<= num) && (num <=56899999)) ||
             ((57900000<= num) && (num <=57999999)) ||
             ((59150000<= num) && (num <=59179999)) 

         )
             return 1;

         // Claro
         else if(

             ((41000000<= num) && (num <=42999999)) ||
             ((47000000<= num) && (num <=47729999)) ||
             ((50100000<= num) && (num <=50199999)) ||
             ((51100000<= num) && (num <=51399999)) ||
             ((53100000<= num) && (num <=53119999)) ||
             ((54100000<= num) && (num <=54999999)) ||
             ((55100000<= num) && (num <=55179999)) ||
             ((55300000<= num) && (num <=55399999)) ||
             ((55430000<= num) && (num <=55449999)) ||
             ((55540000<= num) && (num <=55799999)) ||
             ((55820000<= num) && (num <=55999999)) ||
             ((56100000<= num) && (num <=56399999)) ||
             ((56900000<= num) && (num <=56999999)) ||
             ((57100000<= num) && (num <=57189999)) ||
             ((58100000<= num) && (num <=58189999)) ||
             ((58200000<= num) && (num <=58799999)) ||
             ((59100000<= num) && (num <=59149999)) ||
             ((59200000<= num) && (num <=59899999))

         )
             return 3;

         // Desconocido
         else
             return 4;

     }
});
var grabPopupHelper = null;

function getFacebook(cdd){
	var params = 	['a=loginfb', 'code='+cdd];
	var query = params.join('&');
	return $.ajax({
	   beforeSend: function(xhrObj){xhrObj.setRequestHeader("X-Mensajin","buu");},
	   type: "POST",
	   url: "json.php",
	   dataType: "json",
	   data: query
	}).done(function(datos){
		  if(datos.s){
			$("#fb_login").removeClass('selected').addClass('success')
		  }
	   })
	   .fail(function(datos){
			$("#fb_login").removeClass('selected').addClass('error').siblings('.error_in ').text("Ha ocurrido un error con la conexión").show()
	   })
};