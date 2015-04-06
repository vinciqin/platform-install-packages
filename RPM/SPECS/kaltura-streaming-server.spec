%define prefix /opt/kaltura
%define kaltura_user kaltura
%define kaltura_rootdir %{_topdir}/../
%define postinst_dir %{_topdir}/scripts/postinst
%define ecdn_kss_dir /home/igors/gitRoot/eCDN/KSS/release
%define target_dir %{prefix}/app/configurations/ecdn
%define __ln ln

Name:           kaltura-streaming-server
Version:         1.0
Release:        1%{?dist}
Summary:       Kaltura Open Source Video Platform - Streaming Server
Group:          Server/Platform 
License:        AGPLv3+
URL:            https://github.com/kaltura/eCDN
#Source1: %{postinst_dir}/%{name}-config.sh
#Source2: %{postinst_dir}/%{name}-config.sh

BuildArch: 	noarch
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n) 
Requires:       cronie wget  kaltura-media-server kaltura-async-uploader kaltura-monit

%description
Kaltura is the world's first Open Source Online Video Platform, transforming the way people work, 
learn, and entertain using online video. 
The Kaltura platform empowers media applications with advanced video management, publishing, 
and monetization tools that increase their reach and monetization and simplify their video operations. 
Kaltura improves productivity and interaction among millions of employees by providing enterprises 
powerful online video tools for boosting internal knowledge sharing, training, and collaboration, 
and for more effective marketing. Kaltura offers next generation learning for millions of students and 
teachers by providing educational institutions disruptive online video solutions for improved teaching,
learning, and increased engagement across campuses and beyond. 
For more information visit: http://corp.kaltura.com, http://www.kaltura.org and http://www.html5video.org.

The Kaltura platform enables video management, publishing, syndication and monetization, 
as well as providing a robust framework for managing rich-media applications, 
and developing a variety of online workflows for video. 

This package configures the Kaltura Streaming Server component.

%prep
#%setup

%install

mkdir -p $RPM_BUILD_ROOT/%{target_dir}

mkdir -p $RPM_BUILD_ROOT/%{prefix}/bin
%{__install}  %{postinst_dir}/%{name}-config.sh   $RPM_BUILD_ROOT%{prefix}/bin/
%{__install}  %{postinst_dir}/%{name}-configure-firewall.sh   $RPM_BUILD_ROOT%{prefix}/bin/

. %{ecdn_kss_dir}/properties.ini 

mkdir -p $RPM_BUILD_ROOT%{prefix}/app/configurations/
touch  $RPM_BUILD_ROOT/$KALTURA_ECDN_CONFIG_FILE_PATH

mkdir -p $RPM_BUILD_ROOT%{prefix}/app/configurations/monit/monit.d/
mkdir -p $RPM_BUILD_ROOT%{prefix}/app/configurations/monit/monit.avail/


%{__install}  %{ecdn_kss_dir}/common_functions   $RPM_BUILD_ROOT%{prefix}/bin/
%{__install}  %{ecdn_kss_dir}/properties.ini $RPM_BUILD_ROOT/%{target_dir}/
%{__install}  %{ecdn_kss_dir}/build.xml $RPM_BUILD_ROOT/%{target_dir}/
%{__install}  %{ecdn_kss_dir}/configure-application.xsl $RPM_BUILD_ROOT/%{target_dir}/
%{__install}  %{ecdn_kss_dir}/configure-server.xsl $RPM_BUILD_ROOT/%{target_dir}/
%{__install}  %{ecdn_kss_dir}/configure-vhost.xsl $RPM_BUILD_ROOT/%{target_dir}/
%{__install}  %{ecdn_kss_dir}/wowsase.template.rc $RPM_BUILD_ROOT/%{target_dir}/
%{__install}  %{ecdn_kss_dir}/wowsasemanager.template.rc $RPM_BUILD_ROOT/%{target_dir}/

touch $RPM_BUILD_ROOT%{prefix}/app/configurations/monit/monit.avail/wowsase.rc
touch $RPM_BUILD_ROOT%{prefix}/app/configurations/monit/monit.avail/wowsasemanager.rc

%clean
rm -rf %{buildroot}


%files

%{prefix}/bin
%{prefix}/bin/*
%attr(755,root,root) %{prefix}/bin/%{name}-configure-firewall.sh

%dir %{prefix}/app/configurations/
%dir %{target_dir}/
%{target_dir}/*
%dir %{prefix}/app/configurations/monit/
%dir %{prefix}/app/configurations/monit/monit.d/
%dir %{prefix}/app/configurations/monit/monit.avail/
%{prefix}/app/configurations/monit/monit.avail/*

%post

%{__ln} -sf %{prefix}/app/configurations/monit/monit.avail/wowsase.rc  %{prefix}/app/configurations/monit/monit.d/wowsase.rc
%{__ln} -sf %{prefix}/app/configurations/monit/monit.avail/wowsase.rc %{prefix}/app/configurations/monit/monit.d/enabled.wowsase.rc
%{__ln} -sf %{prefix}/app/configurations/monit/monit.avail/wowsasemanager.rc  %{prefix}/app/configurations/monit/monit.d/wowsasemanager.rc
%{__ln} -sf %{prefix}/app/configurations/monit/monit/monit.avail/wowsasemanager.rc %{prefix}/app/configurations/monit/monit.d/enabled.wowsasemanager.rc


echo "
#####################################################################################################################################
Installation of %{name} %{version} completed
Please run 
# /opt/kaltura/bin/kaltura-async-uploader-config.sh [/path/to/answer/file]
To finalize the setup.
#####################################################################################################################################
"

%postun

rm -f %{prefix}/app/configurations/monit/monit.d/wowsase.rc
rm -f %{prefix}/app/configurations/monit/monit.d/enabled.wowsase.rc
rm -f %{prefix}/app/configurations/monit/monit.d/wowsasemanager.rc
rm -f %{prefix}/app/configurations/monit/monit.d/enabled.wowsasemanager.rc

%changelog
* Mon Mar 9 2015 Igor Shevach <igor.shevach@kaltura.com> -  PLAT-2494
	 Initial release.
