/**
 * @package     Joomla.Site
 * @subpackage  Templates.protostar
 * @copyright   Copyright (C) 2005 - 2016 Open Source Matters, Inc. All rights reserved.
 * @license     GNU General Public License version 2 or later; see LICENSE.txt
 * @since       3.2
 */

var ultimaImmagine = 1;
var numeroImmaginiInGalleria = 4;
var totSecRefresh = 6000;
 
(function($)
{
	$(document).ready(function()
	{
		$('*[rel=tooltip]').tooltip()

		// Turn radios into btn-group
		$('.radio.btn-group label').addClass('btn');

		$('fieldset.btn-group').each(function() {
			// Handle disabled, prevent clicks on the container, and add disabled style to each button
			if ($(this).prop('disabled')) {
				$(this).css('pointer-events', 'none').off('click');
				$(this).find('.btn').addClass('disabled');
			}
		});

		$(".btn-group label:not(.active)").click(function()
		{
			var label = $(this);
			var input = $('#' + label.attr('for'));

			if (!input.prop('checked')) {
				label.closest('.btn-group').find("label").removeClass('active btn-success btn-danger btn-primary');
				if (input.val() == '') {
					label.addClass('active btn-primary');
				} else if (input.val() == 0) {
					label.addClass('active btn-danger');
				} else {
					label.addClass('active btn-success');
				}
				input.prop('checked', true);
			}
		});
		$(".btn-group input[checked=checked]").each(function()
		{
			if ($(this).val() == '') {
				$("label[for=" + $(this).attr('id') + "]").addClass('active btn-primary');
			} else if ($(this).val() == 0) {
				$("label[for=" + $(this).attr('id') + "]").addClass('active btn-danger');
			} else {
				$("label[for=" + $(this).attr('id') + "]").addClass('active btn-success');
			}
		});
		
		//Se sono in home page (trovo quindi l'immagine da far scorrere)
		if ( document.getElementById('img_home_slide') )
		{
			//Ogni 2 secondi cambia immagine
			setInterval('scorriImmagineHomePage()', totSecRefresh);
		}

	})
})(jQuery);

function scorriImmagineHomePage()
{
	var oldSrc = document.getElementById('img_home_slide').src;
	var nuovaImmagine = ((ultimaImmagine == numeroImmaginiInGalleria) ? 0 : ultimaImmagine) + 1; 

	document.getElementById('img_home_slide').src = oldSrc.replace( String(ultimaImmagine) + '.jpg',String(nuovaImmagine) + '.jpg'  );

	ultimaImmagine = nuovaImmagine;
}

