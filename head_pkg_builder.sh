#/usr/bin/env bash
# -bname build name
# -wspace build workspace dir
# -lcommit builds last commit

#read command line args
while getopts b:w:l: option
do
        case "${option}"
        in
                b) BNAME=${OPTARG};;
                w) WSPACE=${OPTARG};;
                l) LCOMMIT=${OPTARG};;
        esac
done

echo Build Name: $BNAME
echo Workspace: $WSPACE
echo Last Commit: $LCOMMIT

#change working directory to the dir for this build
echo Changing working directory to /var/lib/jenkins/workspace
cd /var/lib/jenkins/workspace

# check for the existence of an existing commit file for this
# project
SCRIPTFILE='/var/lib/jenkins/workspace/lastcommit/'$BNAME'.txt'
echo Searching for script file $SCRIPTFILE...
if [ -e $SCRIPTFILE ]
then
        PREVRSA=$(<$SCRIPTFILE) &&
        echo Found previous SHA $PREVRSA

        # Backup existing Package.xml
        cd $WSPACE/src
        echo changing directoy to $WSPACE
        cp package.xml{,.bak} &&
        echo Backing up package.xml to package.xml.bak &&
        read -d '' NEWPKGXML <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<Package>
</Package>
EOF      
        echo ===PKGXML===
        echo $NEWPKGXML
        echo Creating new package.xml
        echo $NEWPKGXML > $WSPACE/src/package.xml

        for CFILE in `git diff-tree --no-commit-id --name-only -r $LCOMMIT $PREVRSA`
        do
                echo Analyzing file `basename $CFILE`

                case "$CFILE"
                in
                        *.cls*) TYPENAME="ApexClass";;
                        *.page*) TYPENAME="ApexPage";;
                        *.component*) TYPENAME="ApexComponent";;
                        *.trigger*) TYPENAME="ApexTrigger";;
                        *.app*) TYPENAME="CustomApplication";;
                        *.labels*) TYPENAME="CustomLabels";;
                        *.object*) TYPENAME="CustomObject";;
                        *.tab*) TYPENAME="CustomTab";;
                        *.resource*) TYPENAME="StaticResource";;
                        *.workflow*) TYPENAME="Workflow";;
                        *.remoteSite*) TYPENAME="RemoteSiteSettings";;
                        *.pagelayout*) TYPENAME="Layout";;
                        *) TYPENAME="UNKNOWN TYPE";;
                esac

                if [[ "$TYPENAME" != "UNKNOWN TYPE" ]]
                then
                        ENTITY=$(basename "$CFILE")
                        ENTITY="${ENTITY%.*}"
                        echo ENTITY NAME: $ENTITY

                        if grep -Fq "$TYPENAME" $WSPACE/src/package.xml
                        then
                                echo Generating new member for $ENTITY
                                xmlstarlet ed -L -s "/Package/types[name='$TYPENAME']" -t elem -n members -v "$ENTITY" $WSPACE/src/package.xml
                        else
                                echo Generating new $TYPENAME type
                                xmlstarlet ed -L -s /Package -t elem -n types -v "" $WSPACE/src/package.xml
                                xmlstarlet ed -L -s '/Package/types[not(*)]' -t elem -n name -v "$TYPENAME" $WSPACE/src/package.xml
                                echo Generating new member for $ENTITY
                                xmlstarlet ed -L -s "/Package/types[name='$TYPENAME']" -t elem -n members -v "$ENTITY" $WSPACE/src/package.xml
                        fi
                else
                        echo ERROR: UNKNOWN FILE TYPE $CFILE
                fi
                echo ====UPDATED PACKAGE.XML====
                cat $WSPACE/src/package.xml
        done
        echo Saving last RSA Commit
        echo $LCOMMIT > /var/lib/jenkins/workspace/lastcommit/$BNAME.txt
        echo Cleaning up Package.xml
        xmlstarlet ed -L -s /Package -t elem -n version -v "27.0" $WSPACE/src/package.xml
        xmlstarlet ed -L -i /Package -t attr -n xmlns -v "http://soap.sforce.com/2006/04/metadata" $WSPACE/src/package.xml

        echo ====FINAL PACKAGE.XML=====
        cat $WSPACE/src/package.xml
else
        echo No RSA found, default Package.xml will be used
        echo Creating new list commit file
        echo $LCOMMIT > /var/lib/jenkins/workspace/lastcommit/$BNAME.txt
fi
