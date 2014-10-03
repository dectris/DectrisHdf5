# 
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

full_list=$(grep CPACK_RPM_PACKAGE_REQUIRES CMakeLists.txt | awk -F'CPACK_RPM_PACKAGE_REQUIRES' '{print $2}' | sed 's/"//g' | sed 's/)//g' | sed 's/ //g' | sed 's/,/ /g')

for i in $full_list; do
    operators=">= <= == > <"
    for operator in $operators; do
	package=$(echo "$i"| grep "$operator" )
	if [ -n "$package" ]; then
	    package=$(echo "$i" | sed "s/$operator/:/g" | cut -d":" -f 1)
	    version=$(echo "$i" | sed 's/$operator/:/g' | cut -d":" -f 2)
	    if [ "$operator" == "==" ];then
		package=$package-$version
	    fi
	    break
	else
	    package=$i
	fi
    done
    echo $package
    list="$list $package"
done
echo "installing $list"

if [ "$1" == "--test" -o "$1" == "-t" ];
then
    echo "<Test> yum install -y $list" 
else
    yum install -y $list
fi
# list=$(echo $full | sed 's/>=/-/g'| sed 's/==/-/g')
# yum install  $list 
# echo $full_list
