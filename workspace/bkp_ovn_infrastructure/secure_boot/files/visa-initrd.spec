Name: visa-initrd-%{hw_type}
Version: 0.1
Release: 1
Summary: Visa Signed initrd for %{hw_type}
License: Commercial
Distribution: Visa Centos
Packager: Visa Inc

%description
Visa signend initramfs for %{hw_type}

%install
cp -r %{my_dir}/myrpm/boot %{buildroot}

%files
%defattr(-,root,root,-)
/boot/*

