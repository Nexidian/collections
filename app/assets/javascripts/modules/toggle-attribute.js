window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  'use strict'

  Modules.ToggleAttribute = function () {
    this.start = function ($element) {
      $element.find('[data-toggle-attribute]').click(function (event) {
        var clicked = event.target
        var toggleAttribute = clicked.getAttribute('data-toggle-attribute')
        var current = clicked.getAttribute(toggleAttribute)
        var closedText = clicked.getAttribute('data-when-closed-text')
        var openText = clicked.getAttribute('data-when-open-text')

        clicked.setAttribute(toggleAttribute, current == closedText ? openText : closedText)
      })
    }
  }
})(window.GOVUK.Modules)
