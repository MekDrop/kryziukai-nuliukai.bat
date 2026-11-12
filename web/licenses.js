/* Keep this classic script compatible with IE6 and Windows 2000-era browsers. */
(function ($) {
    if (!$ || !$.modal) return;
    var modal = $('#license-modal');
    var content = $('#license-content');
    var status = $('#license-status');
    var request = null;
    var generation = 0;
    var trigger;
    var previousOverflow;
    window.kryzLicenseOpen = false;

    function fitContent() {
        var container = $('#license-container');
        container.find('.simplemodal-wrap').css('overflow', 'hidden');
        content.outerWidth(Math.max(40, container.width() - 40));
        content.outerHeight(Math.max(40, container.height() - 150));
    }

    function dimensions() {
        return [Math.max(180, Math.min(700, $(window).height() - 34)),
            Math.max(180, Math.min(760, $(window).width() - 34))];
    }

    // SimpleModal's original focus loop includes inputs only; include links and
    // the scrollable license text, too. Stop Tab before its document handler.
    modal.bind('keydown', function (event) {
        if (event.keyCode !== 9) return;
        var nodes = modal.find('button, a[href], [tabindex="0"]').filter(':visible');
        var index = nodes.index(document.activeElement);
        event.stopPropagation();
        if (event.shiftKey && index <= 0) {
            event.preventDefault();
            nodes.last().focus();
        } else if (!event.shiftKey && (index < 0 || index === nodes.length - 1)) {
            event.preventDefault();
            nodes.first().focus();
        }
    });

    $('[data-license]').attr('aria-haspopup', 'dialog').bind('click', function (event) {
        if ((event.which && event.which !== 1) || event.ctrlKey || event.metaKey || event.shiftKey || event.altKey) return;
        event.preventDefault();
        if (window.kryzLicenseOpen) return;
        trigger = this;
        var current = ++generation;
        var size = dimensions();
        $('#license-title').text($(this).text());
        $('#license-original').attr('href', this.href);
        content.text('').hide().scrollTop(0);
        status.text(modal.attr('data-loading')).show();
        modal.attr('aria-hidden', 'false');
        window.kryzLicenseOpen = true;
        previousOverflow = document.body.style.overflow;
        document.body.style.overflow = 'hidden';
        if (window.kryzSetLicenseInputEnabled) window.kryzSetLicenseInputEnabled(false);
        modal.modal({
            persist: true,
            focus: false,
            closeHTML: '',
            overlayId: 'license-overlay',
            containerId: 'license-container',
            opacity: 75,
            overlayClose: true,
            containerCss: { height: size[0], width: size[1] },
            onShow: function () {
                fitContent();
                modal.find('button').focus();
            },
            onClose: function () {
                window.kryzLicenseOpen = false;
                ++generation;
                if (request) { request.abort(); request = null; }
                modal.attr('aria-hidden', 'true');
                $.modal.close();
                document.body.style.overflow = previousOverflow;
                if (window.kryzSetLicenseInputEnabled) window.kryzSetLicenseInputEnabled(true);
                if (trigger) trigger.focus();
            }
        });
        request = $.ajax({
            url: this.href,
            dataType: 'text',
            success: function (text) {
                if (generation !== current) return;
                content.text(text).show();
                status.text('').hide();
            },
            error: function () {
                if (generation === current) status.text(modal.attr('data-failed')).show();
            }
        });
    });

    $(window).bind('resize.license', function () {
        if (!window.kryzLicenseOpen) return;
        var size = dimensions();
        $.modal.update(size[0], size[1]);
        fitContent();
    });
}(window.jQuery));
