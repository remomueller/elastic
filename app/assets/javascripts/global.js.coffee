jQuery ->
  $(document)
    .on('click', '[data-object~="settings-save"]', () ->
      window.$isDirty = false
      $($(this).data('target')).submit()
      false
    )
