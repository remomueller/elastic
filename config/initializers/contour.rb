# Use to configure basic appearance of template
Contour.setup do |config|
  
  # Enter your application name here. The name will be displayed in the title of all pages, ex: AppName - PageTitle
  config.application_name = DEFAULT_APP_NAME
  
  # If you want to style your name using html you can do so here, ex: <b>App</b>Name
  # config.application_name_html = ''
  
  # Enter your application version here. Do not include a trailing backslash. Recommend using a predefined constant
  config.application_version = Elastic::VERSION::STRING
  
  # Enter your application header background image here.
  config.header_background_image = 'brigham.png'
  
  # Enter your application header title image here.
  config.header_title_image = 'synchronize.png'
  
  # Enter the items you wish to see in the menu
  config.menu_items = [
    {
      name: 'Login', display: 'not_signed_in', path: 'new_user_session_path', position: 'right',
      links: [{ name: 'Sign Up', path: 'new_user_registration_path' }]
    },
    {
      name: 'current_user.name', eval: true, display: 'signed_in', path: 'user_path(current_user)', position: 'right',
      links: [{ html: '"<div class=\"small\" style=\"color:#bbb\">"+current_user.email+"</div>"', eval: true },
              { name: 'Settings', path: 'settings_path' },
              { name: 'Authentications', path: 'authentications_path', condition: 'not PROVIDERS.blank?' },
              { html: "<br />" },
              { name: 'Logout', path: 'destroy_user_session_path' }]
    },
    {
      name: 'About', display: 'not_signed_in', path: 'about_path', position: 'left',
      links: []
    },
    {
      name: 'Downloaders', display: 'signed_in', path: 'downloaders_path', position: 'left',
      links: []
    },
    {
      name: 'Segments', display: 'signed_in', path: 'segments_path', position: 'left', condition: 'current_user.system_admin?',
      links: []
    },
    {
      name: 'Users', display: 'signed_in', name: 'Users', path: 'users_path', position: 'left', condition: 'current_user.system_admin?',
      links: []
    }
  ]
  
  # Enter an address of a valid RSS Feed if you would like to see news on the sign in page.
  # config.news_feed = ''
  
  # Enter the max number of items you want to see in the news feed.
  # config.news_feed_items = 5
  
end