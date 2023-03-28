export BRAZIL_WORKSPACE_DEFAULT_LAYOUT=short
export CDK_DEFAULT_ACCOUNT=647908610912
export CDK_DEFAULT_REGION=us-east-1c

export AUTO_TITLE_SCREENS="NO"

export PROMPT="
%{$fg[white]%}(%D %*) <%?> [%~] $program %{$fg[default]%}
%{$fg[cyan]%}%m %#%{$fg[default]%} "

export RPROMPT=

# Set breakpoint() in Python to call pudb
#export PYTHONBREAKPOINT="pudb.set_trace"

export CORES=32
export BRAZIL_PLATFORM_OVERRIDE=AL2_x86_64
export DEVD=cdeoredevvm.aka.corp.amazon.com
export DEVD2=dev-dsk-cdeore-2b-47a11d75.us-west-2.amazon.com
export DEVD2012=dev-dsk-cdeore-2b-c4b4c395.us-west-2.amazon.com
#export DEVD2012=cdeoredevvm2012.aka.corp.amazon.com

#export LD_LIBRARY_PATH='/home/cdeore/workplace/VantaDataplane/build/LookoutBlackWatch/LookoutBlackWatch-1.0/AL2_x86_64/DEV.STD.PTHREAD/build/private/tmp/brazil-path/testrun.runtimefarm/lib'

export SSLPXYCONF=/workplace/cdeore/VantaSSLProxy/src/VantaSSLProxy/build/private/install/share/examples/sslproxy/my-sslproxy.conf

#VantaSSLProxy
alias sslpxy='sudo LD_LIBRARY_PATH=$(brazil-bootstrap)/lib ./build/bin/sslproxy -D'
alias sslpxycmd='sudo LD_LIBRARY_PATH=$(brazil-bootstrap)/lib ./build/bin/sslproxy -f $SSLPXYCONF'
alias sslpxycmd2='sudo LD_LIBRARY_PATH=$(brazil-bootstrap)/lib ./build/bin/sslproxy -D http 127.0.0.1 8081 up:8000 -k /workplace/cdeore/certs/CS-Cert.key -c /workplace/cdeore/certs/CS-Cert.crt -P'

#BlackwatchTestFramework
alias tfw='pushd /workplace/cdeore/blackwatch/src/LookoutBlackWatchTestFramework'
alias tfwr='timedcmd brazil-runtime-exec sudo run_pytest.sh blackwatchtestframework/tests/counter_mode_test.py::CounterModeTest::test_off_mode --bwapollo' #run a single regular BW test
alias tfwrt='timedcmd brazil-runtime-exec sudo run_pytest.sh blackwatchtestframework/tests/geneve_tls_acl_through_sfe.py::GeneveTLSACLThrough1SFE3SlotTest::test_packets_are_forwarded_to_tls --bwapollo' #run a single vanta test
alias tfwrv='timedcmd brazil-runtime-exec sudo run_pytest.sh blackwatchtestframework/tests/geneve_network_acl_through_sfe.py::GeneveNetworkACLThroughSFETest::test_packets_are_forwarded_to_sfe --bwapollo' #run a single vanta test
alias tfwra='timedcmd brazil-runtime-exec sudo run_pytest.sh blackwatchtestframework/tests/ --bwapollo' #run all tests one after another
alias tfwdeactivate='timedcmd sudo /apollo/bin/runCommand -e LookoutBlackWatch -a Deactivate && ps -AF | grep blackwatch'
alias tfwactivate='timedcmd sudo /apollo/bin/runCommand -e LookoutBlackWatch -a Activate'

# Make sure docker keeps running fine
unset DOCKER_HOST && unset DOCKER_TLS_VERIFY

tls_on () {
     timedcmd aws  network-firewall update-firewall-policy --region us-east-1 \
          --firewall-policy-name cdeore-iad-test --firewall-policy-arn \
          arn:aws:network-firewall:us-east-1:647908610912:firewall-policy/cdeore-iad-test \
          --update-token `my-firewall-policy-update-token` \
          --endpoint-url https://iad.beta.customer.vanta.aws.a2z.com --no-verify-ssl  \
          --firewall-policy '{"StatelessDefaultActions": ["aws:forward_to_sfe"], "StatelessFragmentDefaultActions": ["aws:forward_to_sfe"], "TLSInspectionConfigurationArn": "arn:aws:network-firewall:us-east-1:647908610912:tls-configuration/TLSDeleteDemo-viksau-cert-key-unidir", "StatefulRuleGroupReferences": [{"ResourceArn": "arn:aws:network-firewall:us-east-1:647908610912:stateful-rulegroup/cdeore-beta-iad-drop-all"}]}'
     my-firewall-policy
}

tls_off () {
     timedcmd aws  network-firewall update-firewall-policy --region us-east-1 \
          --firewall-policy-name cdeore-iad-test --firewall-policy-arn \
          arn:aws:network-firewall:us-east-1:647908610912:firewall-policy/cdeore-iad-test \
          --update-token `my-firewall-policy-update-token` \
          --endpoint-url https://iad.beta.customer.vanta.aws.a2z.com --no-verify-ssl  \
          --firewall-policy '{"StatelessDefaultActions": ["aws:forward_to_sfe"], "StatelessFragmentDefaultActions": ["aws:forward_to_sfe"], "StatefulRuleGroupReferences": [{"ResourceArn": "arn:aws:network-firewall:us-east-1:647908610912:stateful-rulegroup/cdeore-beta-iad-drop-all"}]}'
     my-firewall-policy
}

missing_metrics () {
    if [[ $# != 2 ]]; then
        echo "Usage: missing_metrics <cell_name> <az name>"
        return
    fi

    pushd /Users/cdeore/workplace/VantaOpsTools_justin/src/VantaOpsTools;
    brazil-runtime-exec fetch_missing_metrics_locations.py  --mechanic-command-type patch --auto-execute --cell-name $1 --az $2
    popd
}

high_mem () {
    if [[ $# != 1 ]]; then
        echo "Usage: high_mem <cell_name>"
        return
    fi

    pushd /Users/cdeore/workplace/VantaOpsTools_justin/src/VantaOpsTools;
    brazil-runtime-exec fetch_high_mem_util_locations.py --mem-threshold-percent 90.0 --auto-patch --cell-name $1
    popd
}

ticket_summery() {
    today=($(date +%w))
    #today=$((($(date +%w))+$1)) # This is for testing using - for i in {0..6}; do; ./dt $i; echo -----------------------; done
    #echo today = $today - `date -v "+$(( (7-$(date '+%w')+$today)%7 ))d" '+%A'` - `date "+%Y-%m-%d"`

    if [[ $today -eq 1 ]]
    then
        end=$((($today - 1 + 7)%7));
        start=$((7-end))
    else
        start=$((($today - 1 + 7)%7));
        end=$((7-start))
    fi


    startdate=`date -d -${start}days "+%Y-%m-%d"`
    enddate=`date -d +${end}days "+%Y-%m-%d"`

    echo $start - $today - $end
    echo $startdate - $enddate

    pushd ~/workplace/VantaOpsTools/src/VantaOpsTools
    echo "brazil-runtime-exec generate_ticket_summary --start $startdate --end $enddate --resolver-group-key DP"
    timedcmd brazil-runtime-exec generate_ticket_summary --start $startdate --end $enddate --resolver-group-key DP
    popd
}

alias patching_summary='pushd ~/workplace/VantaOpsTools/src/VantaOpsTools; timedcmd brazil-runtime-exec generate_patching_summary --team DP; popd'


update_manifest () {
    if [ $# != 2 ]; then
        echo "Usage:"
        echo "      update_manifest <manifest_path> <ECR path for the new docker image>"
        echo ""
        return
    fi
    
    # For e.g. 825837883985.dkr.ecr.us-east-1.amazonaws.com/bones-deplo-1m14mkb9np8zx:bmbenson_CR-81960139-2022.12.21-14.02
    # Should translate to
    #
    # {
    #    "image_tag": "bmbenson_CR-81960139-2022.12.21-14.02", 
    #    "region": "us-east-1",
    #    "registry_id": "825837883985",
    #    "repository_name": "bones-deplo-1m14mkb9np8zx",
    #    "repository_uri": "825837883985.dkr.ecr.us-east-1.amazonaws.com/bones-deplo-1m14mkb9np8zx"
    # }

    manifest=$1
    image=$2 

    if  [[ $image == http* ]] ;
    then
        for i in {1..10}; do echo ""; done
        echo The docker image name should not start with http
        for i in {1..20}; do echo ""; done
    fi

    image_tag=`echo $image | cut -d ':' -f2`
    region=`echo $image | cut -d '.' -f4`
    registry_id=`echo $image | cut -d '.' -f1`
    repository_name=`echo $image | cut -d ':' -f1 | cut -d '/' -f2`
    repository_uri=`echo $image | cut -d ':' -f1`
    
    tmp=$(mktemp)
    jq ".image_tag = \"$image_tag\" | .region = \"$region\" | .registry_id = \"$registry_id\" | .repository_name = \"$repository_name\" | .repository_uri = \"$repository_uri\"" $manifest > $tmp

    mv "$tmp" "$manifest"
}


_br_docker(){
    echo args=$#
    if [ $# -eq 1 ]; then
        docker_image=825837883985.dkr.ecr.us-east-1.amazonaws.com/bones-deplo-1m14mkb9np8zx:$1-`tm`
    else
        # In this case first arguement will be full path and second argument will be anything so that we pick the whole path as is
        docker_image=$1 
    fi

    printf "\n\nDocker Image to be uploaded will be: \n\t$docker_image\n\n\n"
    pause

    aws ecr --region us-east-1 get-login-password | docker login --username AWS --password-stdin 825837883985.dkr.ecr.us-east-1.amazonaws.com
    pushd ~/workplace/VantaSuricataDockerImage/src/VantaSuricataDockerImage
    #timedcmd brazil-recursive-cmd brazil-build release
    timedcmd docker tag  `bats transform -x DockerImage-1.0 -p VantaSuricataDockerImage-1.0 -t VantaSuricataDockerImageEntrypoint-1.0  2>&1 >/dev/null | tail -1` $docker_image
    timedcmd docker push $docker_image
    popd

}

br_docker(){
    timedcmd _br_docker $1 $2
}


_br_bats_with_docker_image() {
    if [ $# != 1 ]; then
        echo "Usage:"
        echo "      br_bats_with_docker_image <ECR path for the new docker image>"
        echo ""
        exit
    fi

    s3_deployment_folder_uri="s3://bonesbootstrap-vfb-iad-c1-beta-deploymentbucket-9eyyhrqtrl6m/VantaDataplane/codedeploy-release:VantaDataplaneLauncher-1.0:AWSCodeDeploy-1.0:VantaDataplaneCodeDeployTransform-1.0_VantaDataplane/"
    #S3path for PDX Gamma: s3://bonesbootstrap-vfg-pdx-c1-gamma-deploymentbucket-1l1fz4t57mthm/VantaDataplane/codedeploy-release:VantaDataplaneLauncher-1.0:AWSCodeDeploy-1.0:VantaDataplaneCodeDeployTransform-1.0_VantaDataplane/"
    manifest_path="../VantaSuricataDockerLauncher/configuration/suricata_docker_manifest/x86_64/manifest"
    docker_image_path=$1
    docker_iname_name=`echo $docker_image_path | cut -d ':' -f2`

    bats_image=$s3_deployment_folder_uri$USER"_BATS_artifact_with_DockerImage-"$docker_iname_name"_Built_on_`tm`.zip"
    printf "\n\nBATS Image to be uploaded will be: \n\t$bats_image\n\n\n"

    pushd ~/workplace/VantaDP/src/VantaDataplaneLauncher
    update_manifest $manifest_path $docker_image_path
    pause

    timedcmd brazil-recursive-cmd brazil-build release
    timedcmd bats package -x AWSCodeDeploy-1.0 -xp S3-1.0 -p VantaDataplaneCodeDeployTransform-1.0 -t VantaDataplaneLauncher-1.0 -d $bats_image
    popd

}

br_bats_with_docker_image() {
    timedcmd _br_bats_with_docker_image $1
}


_br_bats() {
    if [ $# != 1 ]; then
        echo "Usage:"
        echo "      br_bats <BATs image name>"
        echo ""
        exit
    fi

    s3_deployment_folder_uri="s3://bonesbootstrap-vfb-iad-c1-beta-deploymentbucket-9eyyhrqtrl6m/VantaDataplane/codedeploy-release:VantaDataplaneLauncher-1.0:AWSCodeDeploy-1.0:VantaDataplaneCodeDeployTransform-1.0_VantaDataplane/"
    #"s3://bonesbootstrap-vfg-pdx-c1-gamma-deploymentbucket-1l1fz4t57mthm/VantaDataplane/codedeploy-release:VantaDataplaneLauncher-1.0:AWSCodeDeploy-1.0:VantaDataplaneCodeDeployTransform-1.0_VantaDataplane/"

    bats_image=$s3_deployment_folder_uri$USER"_"$1"_Built_on_`tm`.zip"
    printf "\n\nBATS Image to be uploaded will be: \n\t$bats_image\n\n\n"
    pause

    pushd ~/workplace/VantaDP/src/VantaDataplaneLauncher
    timedcmd brazil-recursive-cmd brazil-build release
    timedcmd bats package -x AWSCodeDeploy-1.0 -xp S3-1.0 -p VantaDataplaneCodeDeployTransform-1.0 -t VantaDataplaneLauncher-1.0 -d $bats_image
    popd
}

br_bats() {
    timedcmd _br_bats $1
}

_br_dpmonitoring() {
    iad_s3_path="s3://bonesbootstrap-vfb-iad-c1-beta-deploymentbucket-9eyyhrqtrl6m/VantaLookoutBlackWatchMonitor/codedeploy-release:VantaDataplaneMonitoringCodeDeploy-1.0:AWSCodeDeploy-1.0:VantaDataplaneMonitoringCodeDeployTransform-1.0_VantaLookoutBlackWatchMonitor/" 
    pdx_s3_path="s3://bonesbootstrap-vfb-pdx-c1-beta-deploymentbucket-akawvw7ys7d3/VantaLookoutBlackWatchMonitor/codedeploy-release:VantaDataplaneMonitoringCodeDeploy-1.0:AWSCodeDeploy-1.0:VantaDataplaneMonitoringCodeDeployTransform-1.0_VantaLookoutBlackWatchMonitor/"

    bats_image=$iad_s3_path$USER"_"$1"_Built_on_`tm`.zip"
    #bats_image=$pdx_s3_path$USER"_"$1"_Built_on_`tm`.zip"

    print $bats_image
    pushd  ~/workplace/VantaDataplaneMonitoring/src/VantaDataplaneMonitoring
    br   
    timedcmd bats package -x AWSCodeDeploy-1.0 -xp S3-1.0 -t VantaDataplaneMonitoringCodeDeploy-1.0 -p VantaDataplaneMonitoringCodeDeployTransform-1.0 -d $bats_image
    popd
}

br_dpmonitoring() {
    timedcmd _br_dpmonitoring $1
} 


_lbwenvbuild(){
	pushd /workplace/cdeore/VantaDataplane/src/IntelDPDK
	timedcmd brazil-build release
        pushd /workplace/cdeore/VantaDataplane/src/LookoutBlackWatchLauncher
	timedcmd brazil-recursive-cmd --allPackages brazil-build release
        #timedcmd brazil-recursive-cmd brazil-build release

	#pushd /workplace/cdeore/VantaDataplane/src/LookoutBlackWatch
	#timedcmd brazil-recursive-cmd brazil-build release 

	if [ $? -eq 0 ]; then 
		brazil ws env attach --alias LookoutBlackWatch --package IntelDPDK --package LookoutBlackWatchLauncher --package LookoutBlackWatch # Brazil CLI 2.0
		#brazil ws env attach --alias LookoutBlackWatch --package LookoutBlackWatchLauncher --package LookoutBlackWatch # Brazil CLI 2.0
	fi

	if [ $? -eq 0 ]; then 
		brazil ws env update
	fi

	popd
}

lbwenvbuild(){
	timedcmd _lbwenvbuild
}

_synproxyrebuild(){
        pushd /workplace/cdeore/LookoutBlackWatchSyncookieModule/src/BlackWatchSynproxyAgent
	bws sync
       	brazil-recursive-cmd --allPackages brazil-build release
	#brazil ws env detach --alias BlackWatchSynproxyAgent  
	brazil ws env attach --clean --alias BlackWatchSynproxyAgent --package BlackWatchSynproxyAgent --package LookoutBlackWatchSyncookieModule
        brazil ws env update
}

synproxyrebuild(){
	timedcmd _synproxyrebuild
}

load_dep(){
	pushd /workplace/cdeore/VantaDataplane/src/LookoutBlackWatch
	sudo insmod /src/IntelDPDK/build/modules/`uname -r`/rte_kni.ko kthread_mode=multiple carrier=on;

	pushd /workplace/cdeore/blackwatch-tests/src/LookoutBlackWatchTestFramework
	timedcmd  ./setup/install_dependency_on_amazon_linux
}

tfwrebuild2() {
	pushd /workplace/cdeore/blackwatch-tests/src/LookoutBlackWatchTestFramework

        srm /workplace/cdeore/blackwatch-tests/build/LookoutBlackWatchTestFramework/LookoutBlackWatchTestFramework-1.0/AL2_x86_64/DEV.STD.PTHREAD/build
	srm /workplace/cdeore/blackwatch/env

	if [ $? -eq 0 ]; then 
		bws clean 	
	fi

	if [ $? -eq 0 ]; then 
		bb clean 
	fi

	if [ $? -eq 0 ]; then 
		timedcmd brazil-recursive-cmd brazil-build release 
	fi
	
	if [ $? -eq 0 ]; then 
		./setup/install_dependency_on_amazon_linux 
	fi
	
	if [ $? -eq 0 ]; then 
		ln -sf `brazil-bootstrap --environmentType runtime`
	fi

	if [ $? -eq 0 ]; then 
        	ln -sf `brazil-bootstrap --environmentType test-runtime` 
	fi
	
	if [ $? -eq 0 ]; then 
		tfwdeactivate 
	fi

	echo $(brazil-path testrun.runtimefarm)/bin/python | pbcopy

	popd
}

tfwrebuild() {
        pushd /workplace/cdeore/blackwatch-tests/src/LookoutBlackWatchTestFramework

        srm /workplace/cdeore/blackwatch-tests/build/LookoutBlackWatchTestFramework/LookoutBlackWatchTestFramework-1.0/AL2_x86_64/DEV.STD.PTHREAD/build
        srm /workplace/cdeore/blackwatch-tests/env

        if [ $? -eq 0 ]; then
                bws clean
        fi

        if [ $? -eq 0 ]; then
                bb clean
        fi

        if [ $? -eq 0 ]; then
                timedcmd brazil-recursive-cmd brazil-build release
        fi

        if [ $? -eq 0 ]; then
                ./setup/install_dependency_on_amazon_linux
        fi

        if [ $? -eq 0 ]; then
                ln -sf `brazil-bootstrap --environmentType runtime`
        fi

        if [ $? -eq 0 ]; then
                ln -sf `brazil-bootstrap --environmentType test-runtime`
        fi

        if [ $? -eq 0 ]; then
                tfwdeactivate
        fi
	
	echo $(brazil-path testrun.runtimefarm)/bin/python | pbcopy

        popd
}



_tfw-lbwenv-rebuild(){
	lbwenvbuild 
	if [ $? -eq 0 ]; then
		tfwrebuild
	fi
}
	
tfw-lbwenv-rebuild(){
	timedcmd _tfw-lbwenv-rebuild
}

mechanic_helper (){
    length=$(($# - 1))
    readonly region=${1:?"The Region must be specified. Usage: mechanic_helper <region> <domain>"}
    readonly domain=${2:?$"The Domain must be specified. Usage: mechanic_helper <region> <domain>"}

    pushd ~/workplace/VantaOpsTools/src/VantaOpsTools/ 
    brazil-runtime-exec mechanic_helper.py  --region $region --domain $domain -x
    echo "Run 'popd' to switch back to previous directory!"
}

set-title() {
    echo -e "\e]0;$*\007"
}

ssh() {
    set-title $*;
    /usr/bin/ssh -2 $*;
    set-title $HOST;
}

printdatetime() {
    echo $1: `date`
}

srch() {
    length=$(($# - 1))
	    
    if [[ $length>0 ]]; then
        names=${@:1:$length}  #all args but last
        path_to_search_in="${@: -1}" #last arguement
    else
        names=$@ #single arg
        path_to_search_in="." #current dir
    fi

    timedcmd eval find $path_to_search_in -name $names -exec ls -l {} +
}

st() {
    echo "Usage: st <text to search> [optional list of extension for the files to search the text in]"
    echo "       Searches text from files recursively in the current directory onwards. Optionaly provide file extension to restrict search only in files with that extension"
    echo "       For searching multiple words, inclose the words in quotes and separate them by \\\\\\\\\| "
    echo "       Example: st 'bps\\\\\\\\\|pps' c cpp txt json" 
    echo

    length=$(($# - 1))

    if [[ $length>0 ]]; then
        text_to_search=$1  #first arg
        files_to_search_in=""
        #files_to_search_in="--include \\*.${@:2}" #all but first arguements
        for ext in "${@:2}"
        do 
            files_to_search_in="$files_to_search_in --include \*.$ext"
        done #all but first arguements

        #text_to_search=${@:1:$length}  #all args but last
        #files_to_search_in="--include \\*.${@: -1}" #last arguement
    else
        text_to_search=$@ #single arg
        files_to_search_in="*" #all files
    fi

    eval grep -rn $text_to_search $files_to_search_in
    echo
    echo Finished running \"grep -rn \'${text_to_search//\\\\/\\}\' $files_to_search_in\"
}  

timedcmd() {
    local Epoch=`date`;
    
    $@; #Run the command 

    echo "";
    echo "Finished running  : '$@'";
    echo "Command start time: ${Epoch}";
    echo "Command end time  : `date`";
}

function kj () {
    local kill_list="$(jobs)"
    
    if [ -n "$kill_list" ]; then
        # this runs the shell builtin kill, not unix kill, otherwise jobspecs cannot be killed
        # the `$@` list must not be quoted to allow one to pass any number parameters into the kill
        # the kill list must not be quoted to allow the shell builtin kill to recognise them as jobspec parameters
        kill $@ $(sed -r 's/\[([[:digit:]]+)\].*/%\1/gp' <<< "$kill_list" | tr '\n' ' ')
    else
        echo "No jobs to kill"
	return 0
    fi
}

gda() {
   git diff --name-only "$@" | while read filename; do
      (&>/dev/null git difftool "$@" --no-prompt "$filename" &)
   done
}

alias x='exit'
alias c='clear'
alias p='pwd'
alias i='mwinit -s --aea -o'
alias in='kinit && mwinit -o --aea -s'
alias iv=' printdatetime "        Current Time"; ssh-keygen -L -f ~/.ssh/id_rsa-cert.pub | grep Valid'
alias minfo='cat /etc/hardware.amazon.stanza'
alias t='tail -f'
alias tm='date "+%Y.%m.%d-%H.%M"'
alias ts='date "+%Y.%m.%d-%H.%M.%S"'
alias src='pushd /workplace/cdeore/VantaDP/src/LookoutBlackWatch/'

alias aws='/usr/local/bin/aws'

alias csd='ssh $DEVD'
alias csdg='python3 ./dcv-cdd.py connect $DEVD'
alias csdin='ssh -t $DEVD echo Authenticate yourself on the cloud desktop && kinit && mwinit -s --aea -o && clear'
alias scpcd='tmpfn() { echo scp "$1" cdeore@$DEVD:"$2"; scp "$1" cdeore@$DEVD:"$2";  unset -f tmpfn; }; tmpfn'

alias csd2='ssh $DEVD2'
alias csdg2='python3 ./dcv-cdd.py connect $DEVD2'
alias csdin2='ssh -t $DEV2 echo Authenticate yourself on the cloud desktop && kinit && mwinit -s --aea -o && clear'
alias scpcd2='tmpfn2() { echo scp "$1" cdeore@$DEVD2:"$2"; scp "$1" cdeore@$DEVD2:"$2";  unset -f tmpfn2; }; tmpfn2'

alias csd2='ssh $DEVD2012'
alias csdg2='python3 ./dcv-cdd.py connect $DEVD2012'
alias csdin2='ssh -t $DEV2012 echo Authenticate yourself on the cloud desktop && kinit && mwinit -s --aea -o && clear'
alias scpcd2='tmpfn2() { echo scp "$1" cdeore@$DEVD2012:"$2"; scp "$1" cdeore@$DEVD2012:"$2";  unset -f tmpfn2; }; tmpfn2'

alias ezsh='vi ~/.zshrc && source ~/.zshrc'
alias pause='echo "Press any key to continue..."; read -k1 -s'
alias l='ls -althFG'
alias cd..='cd ..'
alias l..='l ..'
alias p3='python3'
alias gdiff='git difftool -y'
alias gd='gda'
alias ga='git add'
alias gm='git commit -m'
alias gmm='git commit --amend -m'
alias gam='git commit --amend --no-edit'
alias gitamend='git commit --amend --no-edit'
alias gl='git log -n'
alias gs='git status'
alias gsall='for d in *; do; (printf "\n\n\n**************************************************************************\ngit status for \"$d\":\n"; pushd "$d"; git status; popd); done'
alias gb='git branch -a'
alias gcr='Git switch -c'
alias gsw='git switch'
alias gp='git pull --rebase'
alias gst='git stash'
alias gstl='git stash list'

alias pse='ps -axjf | grep '
alias kl='sudo kill -9'
alias e=emacs
alias sl=subl
alias srm='sudo rm -rf '

alias b='brazil'
alias bws='brazil ws'
alias bwscreate='bws create -n'
#alias bwscr='bws create -n'
#unalias bwscr
bwscr () { cd ~/workplace; brazil ws create --root $1; cd $1; echo "bws create --root -n $1"; }
#unalias bwsuse
bwsuse () { brazil ws use -p $1; cd src/$1; }
alias bwsls='bws show'
alias bwsdel='bws delete --root'
alias bwsrm='bws delete --root'
alias bwsrmp='bws remove -p'
alias bwspl='bws use -platform AL2_x86_64'
alias bwscl='bws clean'
alias bcl='bwscl'
alias bwssync='bws sync'
alias bb='timedcmd brazil-build' # -j $CORES'
alias br='timedcmd brazil-recursive-cmd brazil-build release' # -j $CORES'
#alias br='printdatetime "Build start time" > /tmp/tmpdtm; brazil-build release -j $CORES; cat /tmp/tmpdtm; printdatetime "Build end time  "; rm /tmp/tmpdtm;'

alias bba='timedcmd brazil-build apollo-pkg' # -j $CORES'
alias bre='timedcmd brazil-runtime-exec' # -j $CORES'
#alias brc='timedcmd brazil-recursive-cmd' # -j $CORES'
#alias bbr='timedcmd brazil-recursive-cmd brazil-build'
alias bball='br --allPackages'
alias bbb='timedcmd brazil-recursive-cmd --allPackages brazil-build'
alias bbra='bbr apollo-pkg'
alias bbc='timedcmd brazil-build clean'
alias bbbc='timedcmd brazil-recursive-cmd --allPackages brazil-build clean'

alias bwsattach='timedcmd brazil workspace env attach --alias'
alias bwsattachlbw='timedcmd brazil workspace env attach --alias LookoutBlackWatch; timedcmd brazil ws env update'

alias bwtest=tools/standalone/run_test-runtime_unit_tests.sh
export bwtest=tools/standalone/run_test-runtime_unit_tests.sh

alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'

export PATH=$HOME/.toolbox/bin:/opt/slickedit/bin:$PATH

autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit
complete -C '/usr/local/bin/aws_completer' aws

# Enable autocompletion for mechanic.
[ -f "$HOME/.local/share/mechanic/complete.zsh" ] && source "$HOME/.local/share/mechanic/complete.zsh"


#"${HOME}"/bin/k5renewer

export NPM_HOME=/apollo/env/NodeJS
export PATH=$NPM_HOME/bin:$PATH
 

export AWS_EC2_METADATA_DISABLED=true

