# Author: Remo Mueller
# Date: 17 October 2011
# Description: Notes on installing elastic file server on windows as a Windows Service and running using the Thin Ruby on Rails server



# Install Elastic

  Open Git Bash and go to your preferred Elastic folder.

  This install assumes you'll install it in c:\web\elastic

    cd c:

    mkdir web

    cd web

    git clone git://github.com/remomueller/elastic.git

  Type 'yes' if it asks you to add the RSA key fingerprint.

    cd elastic

  Install required gems

    bundle install

  Run Initial Setup to Stage remaining required files

    ruby lib/initial_setup.rb

  Type possibly bundle exec rake db:migrate

    rake db:migrate RAILS_ENV=production


# How to startup server in case the service approach does not work or for initial testing.

  thin start -p [my_port_number] -e production


# Based on information from: http://unicornless.com/systems-administration/run-thin-as-windows-service
# Installing as a service

# Windows 7 Instructions (modified from www.dixis.com/?p=140):
  Download and Install Resource Kit for Windows 2003
  http://www.microsoft.com/downloads/details.aspx?familyid=9d467a69-57ff-4ae7-96ee-b18c4790cffd&displaylang=en

# Create the empty service placeholder

  C:\Program Files\Windows Resource Kits\Tools> instsrv "[my_service_name]" "c:\program files\Windows Resource Kits\Tools\srvany.exe"

# Create Parameters folder under the [my_service_name] Registry key
# Use regedit.  WARNING! Remember to back your registry before making changes.
# INCORRECT EDITS CAN CAUSE YOUR COMPUTER TO STOP FUNCTIONING!

  HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\[my_service_name]\Parameters

# Add the following keys to the Parameters folder:
  [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\[my_service_name]\Parameters]

  Application=c:\Ruby192\bin\ruby.exe
  AppDirectory=c:\web\elastic
  AppParameters=c:\Ruby192\bin\thin start -p [my_port_number] -e production

# Remember to set your service to autorestart
# In Services Panel->[my_service_name]->Properties->General, set:
  Startup type: Automatic

# In Services Panel->[my_service_name]->Properties->Recovery, set:
  First failure: Restart the Service
  Second failure: Restart the Service
  Subsequent failures: Restart the Service

# In Services Panel->[my_service_name]->Properties->Log On, set:
  Log on as: Local System account

# You can now startup your server by either restarting Windows or clicking Start on [my_service_name]
# Note: The server startup may not appear to start immediately as it loads in the background.
# Give it about 2 minutes (min) to 5 minutes (max) to start up. And navigate your browser to:
  http://localhost:[my_port_number]/