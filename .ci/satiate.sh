#!/bin/bash 
#
# Basic implementation of package dependency resolvement for the docker builder
#
# Comments doesn't handle yet >=, <=, < and >
#
# ====
# sa·ti·ate - Verb, Arcaic - [ˈsā-sh(ē-)ət]
# - Definition: to satisfy (as a need or desire) fully or to excess
# ====


#getting list of rpm dependencies from the RPM variable in the CMakefile
full_list=$(grep "(CPACK_RPM_PACKAGE_REQUIRES" CMakeLists.txt                      | awk -F'CPACK_RPM_PACKAGE_REQUIRES'       '{print $2}' | sed 's/"//g' | sed 's/)//g' | sed 's/ = /==/g'| sed 's/ //g' | sed 's/,/ /g')
full_list="${full_list} "$(grep "(CPACK_BUILD_RPM_PACKAGE_REQUIRES" CMakeLists.txt | awk -F'CPACK_BUILD_RPM_PACKAGE_REQUIRES' '{print $2}' | sed 's/"//g' | sed 's/)//g' | sed 's/ = /==/g'| sed 's/ //g' | sed 's/,/ /g')

DIST_TAG=".$(rpm --showrc | grep dist| grep '\.el' | awk -F ' ' '{print $3}' | cut -d "." -f2)"
full_list=$(eval "echo $full_list")
for i in $full_list; do
    operators=">= <= =="
    for operator in $operators; do
        package=$(echo "$i"| grep "$operator" )
        if [ -n "$package" ]; then
            package=$(echo "$i" | sed "s/$operator/:/g" | cut -d":" -f 1)
            version=$(echo "$i" | sed "s/$operator/:/g" | cut -d":" -f 2)
            if [ "$operator" == "==" ];then
                operator="="
                #echo "<$package> <$operator> <$version>"
                echo $package-$version
                package="$package-$version"

            fi
            break
        else
           package=$i
        fi
    done
    # echo $package
    list="$list $package"
done

yum clean all
# Workaround for https://bugzilla.redhat.com/show_bug.cgi?id=736694 as suggested in 
# http://serverfault.com/questions/694942/yum-should-error-when-a-package-is-not-available
for pkg in ${list}; do
    # Stop executing if at least one package isn't available:
    echo "[echo] > yum info ${pkg}  || echo 'Error fetching info for [${pkg}]'; exit 1"
    yum info ${pkg} ||  exit $?
done

echo "[echo] > yum install -y $list"
yum install -y $list || exit $?


