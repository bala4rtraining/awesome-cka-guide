#
#  Filename:  ovn_jenkins_pipeline/Makefile
#  Purpose:   Makefile for the ovn_jenkins_pipeline repository
#             Tarball the jenkins XML files, using current jenkinsfile pipeline files in cd_pipeline
#
JOBTEMPLATE  := cd_pipeline/jenkinsjob.config.xml.j2
CDJOBDIR     := cd_pipeline
TEMPDIR      := _tempdir

.PHONY: all clean generate generatetarball
all: generatetarball
generatetarball: generate jenkinsCDjobs.tar.gz

jenkinsCDjobs.tar.gz:
# Create a tar from all the files in $(TEMPDIR)
	@printf "TARBALL generation start ..."
	@cd $(TEMPDIR);tar -czf ../$@ */*.xml
	@printf "\033[1;32m[Done]\033[0m \nGenerated archive: $@\n"
	@rm -rf $(TEMPDIR)

clean:
	@rm -rf $(TEMPDIR)
	@rm -f jenkinsCDjobs.tar.gz

# generate job files
generate:
	@rm -rf $(TEMPDIR)
	@mkdir $(TEMPDIR)
	@sh jenkins-sh/genjobfiles.sh $(JOBTEMPLATE) $(CDJOBDIR) $(TEMPDIR)
