Name: visa-grub
Version: 0.1
Release: 1
Summary: Visa Signedi GRUB2 EFI loader
License: Commercial
Distribution: Visa Centos
Packager: Visa Inc

%description
Visa Signedi GRUB2 EFI loader

%install
cp -r %{my_dir}/myrpm/boot %{buildroot}

%files
%defattr(-,root,root,-)
/boot/*

