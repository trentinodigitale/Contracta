/*
 * Created by Crative Core s.r.l. 
 * www.creativecore.it
 *
 */

var Modal = {
	
	width:500,
	height:400,
	cssClass:'gray',
	fx : null,
	onComplete: function(){
		var url = (this.href.indexOf('?') > -1)?this.href+'&ajax=1':this.href+'?ajax=1'; 
		new Ajax(url,{method:'get',onComplete:function(response){
				Modal.setContent(response);
			}
		}).request();
	},
	
	init: function(){
  if(!$chk($(modal))){
   
   new Element('div').setProperty('id',"overlay").setOpacity(0.4).injectInside(document.body);
   
   var modal = new Element('div').setProperties({id:"modal",tabindex:0}).injectInside(document.body);
   var box = new Element('div').setProperty('id',"mb_box").injectInside(modal);
   var h2 = new Element("h2").setProperty("id","mb_title").injectInside(box);
   new Element('span').injectInside(h2);
   new Element('a').setProperties({id:'closelbl',accesskey:'x'}).setHTML("chiudi x").injectInside(h2).addEvent('click',Modal.hide);
   new Element('div').setProperty('id','mb_content').addEvents({
    'mousedown':function(ev){
     ev = new Event(ev).stopPropagation();
    },
    'mousewheel':function(ev){     
     try{
      ev = new Event(ev).stopPropagation();  
      var size = $(ev.target).getSize();
      if(ev.wheel > 0 && size.scroll.y == 0) ev.preventDefault();
      if(ev.wheel < 0 && size.scroll.y == (size.scrollSize.y-size.size.y)) ev.preventDefault();
     }catch(e){}
    }
   }).injectInside(box);
  Modal.fx = new Fx.Styles('modal',{duration:1000,wait:false});
  
 } 
 var links = $$("a[rel^=modal]");
 if(links.length > 0){
  links.addEvent('click',function(ev){           
   ev = new Event(ev).preventDefault();
   var target = window.ie?$(ev.target):ev.target;
   
   while(target.tagName.toLowerCase() != 'a'){
    target = target.getParent();
   }
   
   Modal.show(target);
  });  
 }
},


	show:function(lnk){
		var opts = lnk.rel.replace("modal","").replace("[","").replace("]","").split('|');
		var modal = $('modal');
		Modal.width = opts[0];
		Modal.height = opts[1];
		Modal.cssClass = opts[2];	
		if(window.ie6) $$("select").setStyle("visibility","hidden");		
		$('overlay').setStyle('display','block');		
		$('overlay').setStyle('height',window.screen.availHeight);
		
		$('mb_box').addClass(Modal.cssClass).setStyle('height',(Modal.height-25)+'px');
		$('mb_title').getFirst().setHTML(lnk.title);
		modal.addEvent('mousedown',function(ev){
			ev = new Event(ev);
			var modal = $('modal');
			Modal.fx.start({'opacity':[1,0.8]});
			modal.removeEvents();
			var drag = modal.makeDraggable({
				droppables: [document.body],
				onComplete: function(){
						Modal.fx.start({'opacity':[0.8,1]});
				}
			});
			drag.start(ev);
		});
		
		var coord = lnk.getCoordinates();
		Modal.startPosition = {x:coord.left,y:coord.top};
		modal.setStyles({display:'block'});
		
    Modal.fx.start({
		  'width': [0,Modal.width],
			'height': [0,Modal.height],
			'margin-left':[0,-(Modal.width/2)],
			'margin-top':[0,-(Modal.height/2)],
			'left':[coord.left,(window.screen.availWidth/2)],
			'top':[coord.top,((window.screen.availHeight/2)+Window.getSize().scroll.y)],
			'opacity':[0,1]
		});
		Modal.onComplete.delay(1000,lnk);
	},
	
	hide: function(){
	try{
		Modal.fx.start({
			'width': [Modal.width,0],
			'height': [Modal.height,0],
			'margin-left':[-(Modal.width/2),0],
			'margin-top':[-(Modal.height/2),0],
			'left':[(window.screen.availWidth/2),Modal.startPosition.x],
			'top':[((window.screen.availHeight/2)+Window.getSize().scroll.y),Modal.startPosition.y],
			'opacity':[1,0]
		});
		Modal.hidden.delay(1050);
		$('mb_content').innerHTML = '';
		$('mb_box').removeClass(Modal.cssClass);
		$('overlay').setStyle('display','none');
		  if(window.ie6) $$("select").setStyle("visibility","visible");
	}catch(e){};
	},
	
	setContent:function(html){
		$('mb_content').setHTML(html);
		Modal.scanForm();		
		Modal.scanLink();
	},
	
	scanForm:function(){
		var forms = $$('#mb_content form');
		if($chk(Forms)){
			forms.each(function(form){								
				Forms.initForm(form);										
			});
			
			forms.addEvents({
				'afterValidation':function(valid){
					if(valid) $(this).send({
						onComplete:function(response){
							try {
								eval(response);
							}catch(e){
								Modal.setContent(response);
							}
							
						}
				}	);
				},
				'submit':function(ev){
					ev = new Event(ev).preventDefault();
				}
			});
		}else{	
			$$('#mb_content form').addEvent('submit',function(ev){
				ev = new Event(ev).preventDefault();
				$(ev.target).send();
			});		
		}
	},
	
	scanLink:function(){
	    $$('.modal').addEvent('click',function(ev){
	        ev = new Event(ev).preventDefault();
	        var http =new Ajax(this.href,{method:'post',onComplete:function(response){
					Modal.setContent(response);
	            }
	        });
	        http.request();
	    });
	},
	
	hidden: function(){
		$('modal').setStyle('display','none');
	}	
}
var accordion = null;
window.addEvent('domready',function(){
	Modal.init();
	var printbtn = $('printbtn');
	if($chk(printbtn)){
		printbtn.addEvent('click',function(ev){
			ev = new Event(ev).preventDefault();
			window.print();
		});
	}
	accordion = new Accordion('h3.atStart', 'div.atStart', {
		opacity: false
		,
		onActive: function(toggler, element){
			toggler.setStyle('color', '#FFF');
		},
		onBackground: function(toggler, element){
			toggler.setStyle('color', '#FEDE9C');
		}
	}, $('accordion'));	

	
	var registerform = $('FormCens');
		if($chk(registerform)){
		$$('.element input.btn').each(function(button){
			if(button.type != 'submit'){										   
				button.addEvents({
					'click':function(ev){
						ev = new Event(ev).preventDefault();
						var div = $(ev.target).getParent().getParent().getParent();
						var index = accordion.elements.indexOf(div);
						if(Forms.validateFieldset($(this).getParent().getParent())) 
							accordion.display(index+1);
					}
				});
			}
		});
		/*
		$$('.toggler').addEvent('click',function(ev){
			ev = new Event(ev);
			var div = $(this).getNext();			
			var index = accordion.elements.indexOf(div);
			if(index > 0){
				index--;
				div = $(this).getPrevious();
			}
			
			if(!Forms.validateFieldset(div.getFirst())){
				accordion.display(index);
			}
		});
		*/
		registerform.addEvent('submit',function(ev){
			ev = new Event(ev);
			var rb =$('privacyagree');
			if(!rb.checked){
				rb.getParent().setStyles({fontWeight:'bold',color:'#F00'});
				ev.preventDefault();
			}else rb.getParent().setStyles({fontWeight:'normal',color:'#000'});
		});		
		registerform.addEvent('afterValidation',function(){
			var tags = $$('.error');
			if (tags.length > 0){
				var tag = $(tags[0]);
				while(!tag.hasClass('element')){
					tag = tag.getParent();
				}
				var index = accordion.elements.indexOf(tag);
				accordion.display(index);
			}
		});
	}
	
	$$('.ext').addEvent('click',function(ev){
		
		ev = new Event(ev).preventDefault();
		window.open(this.href,'partner');		
	});
});

var tipsfx = {};
	window.addEvent('domready',function(){
	 	$$('div.tipscontent').each(function(div){
			tipsfx[div.id] = new Fx.Slide(div.id);
		});
		
		$$('div.tipsbar').addEvent('click',function(ev){
			ev = new Event(ev).preventDefault();
			var target = $(ev.target);
			if(target.getTag() =='a'){
				var id = target.href.substring(target.href.indexOf('#')+1);
				tipsfx[id].toggle();
				if(target.hasClass('suggest')) target.getPrevious().setStyle('display','inline');
				else  target.getNext().setStyle('display','inline');
				target.setStyle('display','none'); 
			}
		});
		

        if(window.ie6){
            ieMinWidthFix();
	        window.onresizeend = ieMinWidthFix;	    	    
	    }    
		
	});

/* fix per la larghezza minima con IE 6*/
function ieMinWidthFix(){
    
         /*   if(Window.getWidth() < 931) $('main').setStyle('width','890px');
	else if(Window.getWidth() > 1100) $('main').setStyle('width','1100px');
	else $('main').setStyle('width','auto');
    */
}	