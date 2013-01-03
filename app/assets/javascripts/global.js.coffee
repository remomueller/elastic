jQuery ->

  window.$isDirty = false
  msg = 'You haven\'t saved your changes.'

  $(document).on('change', ':input', () ->
    if $("#isdirty").val() == '1'
      window.$isDirty = true
  )

  $(document).ready( () ->
    window.onbeforeunload = (el) ->
      if window.$isDirty
        return msg
  )

  $(document)
    .on('click', '[data-object~="settings-save"]', () ->
      window.$isDirty = false
      $($(this).data('target')).submit()
      false
    )
