def call(Map params) {
  withCredentials([usernamePassword(credentialsId: params.credentialsId, passwordVariable: 'BD_PASSWORD', usernameVariable: 'BD_USERNAME')]) {
    sh """
    OPTIONS="--blackduck.hub.url=$params.url \
      --blackduck.hub.username=\$BD_USERNAME \
      --blackduck.hub.password=\$BD_PASSWORD \
      --detect.cleanup=false \
      --detect.source.path=$params.sourcePath \
      --detect.output.path=$params.outputPath \
      --detect.project.name=$params.projectName \
      --detect.project.version.name=$params.version \
      --detect.hub.signature.scanner.paths=$params.scanPaths"

    if [ "$params.excludedBomTools" != "-" ]; then
      OPTIONS="\$OPTIONS --detect.excluded.bom.tool.types=$params.excludedBomTools"
    fi

    if [ "$params.scanNameExclusionPatterns" != "-" ]; then
      OPTIONS="\$OPTIONS --detect.hub.signature.scanner.exclusion.name.patterns=$params.scanNameExclusionPatterns"
    fi

    if [ "$params.scanPathExclusionPatterns" != "-" ]; then
      OPTIONS="\$OPTIONS --detect.hub.signature.scanner.exclusion.patterns=$params.scanPathExclusionPatterns"
    fi

    if [ "$params.dryRun" == "true" ]; then
      cd $params.outputPath
      curl -sLO $params.url/download/scan.cli.zip
      unzip scan.cli.zip
      rm -f scan.cli.zip
      OPTIONS="\$OPTIONS --blackduck.hub.offline.mode=true --detect.hub.signature.scanner.offline.local.path=\$(find $params.outputPath -name scan.cli-* -type d) --detect.hub.signature.scanner.dry.run=true"
    else
      OPTIONS="\$OPTIONS --detect.risk.report.pdf=true --detect.risk.report.pdf.path=$params.outputPath"
    fi

    java -Dsun.java2d.cmm=sun.java2d.cmm.kcms.KcmsServiceProvider -jar /opt/BD/hub-detect.jar \$OPTIONS

    cd $params.outputPath
    archive=\$(echo "${params.projectName}_${params.version}_BlackDuck_Scan.zip" | tr '/' '_')
    zip -r $params.outputPath/\$archive *_BlackDuck_RiskReport.pdf scan/HubScanLogs
    """
  }
}
