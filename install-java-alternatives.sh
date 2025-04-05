#!/bin/bash
ALTERNATIVE_DIR=$1/bin

echo Updating Alternatives for path: $ALTERNATIVE_DIR

previous_priority=0
for file in /usr/lib/jvm/.*.jinfo; do

    if [ "$priority" != "$previous_priority" ]; then 
        previous_priority=$priority
    fi
    priority=$(cat $file | grep "priority=" | cut -d "=" -f2)
    echo "Previous priority :" $previous_priority
    echo "Current priority :" $priority

    if (( "$priority" -gt "$previous_priority" )); then 
        ((PRIORITY_TO_ASSIGN=priority+1))
    else
        ((PRIORITY_TO_ASSIGN=previous_priority+1))
    fi

    echo "Priority to assign :" $PRIORITY_TO_ASSIGN
done

FULL_PATH_ARRAY=( "$1/lib/jexec" )

update_alternatives() {
    echo sudo update-alternatives --install /usr/bin/$1 $1 $2 $3
}

HL_ARRAY=("java" "jpackage" "keytool" "rmiregistry" "jexec")
JDKHL_ARRAY=("jar" "jarsigner" "javac" "javadoc" "javap" "jcmd" "jdb" "jdeprscan" "jdeps" "jfr" "jimage" "jinfo" "jlink" "jmap" "jmod" "jps" "jrunscript" "jshell" "jstack" "jstat" "jstatd" "serialver" "jhsdb")
JDK_ARRAY=("jconsole")

NAME=$(sed -r "s|[A-z=,.-_0-9]+\/||g" <<< $1)
echo $NAME

#Set variable set_var $var_name $var_value $path_target_file
set_var() {
    local var_name=$1
    local var_value=$2
    local location=$3
    echo var_name=$var_name \n var_value=$var_value \n location=$location
    if ! is_var_present $location $var_name; then
    # theme_variables file should be present in the same folder as this file
        sudo sed -i -E "s/$var_name=[0-9A-Za-z\"]+/$var_name=$var_value/g" $location 
    else
        sudo_append "$var_name=$var_value" $location
    fi
}

sudo_append(){
    (echo "$1" | sudo tee -a "$2")
}

is_var_present() {
    local var_name=$(cat $1 | grep "$2=")
    echo "Is variable present ? $var_name"
    [[ -z "$var_name" ]]
}

concat() {
    echo $1$2
}

# GENERATE .jinfo file
create_jinfo_file() {
    local file_path="/usr/lib/jvm/"
    local file_name=$(ls -a "$file_path" | grep ".$1.jinfo")
    local full_path_file=$(concat $file_path $file_name)
    if [ -z "$file_name" ]; then
        file_name=".$1.jinfo"
        full_path_file=$(concat $file_path $file_name)
        sudo touch $full_path_file
    fi
    echo $full_path_file
}


contains_bin_line() {
    local line=$(cat $1 | grep $2)
    [[ $line =~ $2 ]]
}

append_hl_group() {
    if ! contains_bin_line $1 $2; then
        sudo_append "hl $3 $2" $1
    fi
}

append_jdkhl_group() {
    if ! contains_bin_line $1 $2; then
        sudo_append "jdkhl $3 $2" $1
    fi
}

append_jdk_group() {
    if ! contains_bin_line $1 $2; then
        sudo_append "jdk $3 $2" $1
    fi
}

array_contains() {
    local -n array_name=$1
    [[ " ${array_name[*]} " =~ " $2 " ]]
}

generate_jinfo_file() {

    local full_path_file=$(create_jinfo_file $1)
    echo "Setting variables for ${full_path_file}"
    set_var "name" "$1" "$full_path_file"
    set_var "priority" "${PRIORITY_TO_ASSIGN}" "$full_path_file"
    set_var "section" "main" "$full_path_file"
    sudo_append " " $full_path_file
    JINFO_FILE_PATH=$full_path_file
}

generate_jinfo_file $NAME

for file in $ALTERNATIVE_DIR/*; do 
    full_path_file=$file
    file=$(sed "s|${ALTERNATIVE_DIR}\/||g" <<< $file) 
    FULL_PATH_ARRAY+=("$full_path_file")
    if array_contains HL_ARRAY $file; then
        if ! contains_bin_line $JINFO_FILE_PATH "$1/lib/jexec"; then
            update_alternatives jexec "$1/lib/jexec" $PRIORITY_TO_ASSIGN
            append_hl_group $JINFO_FILE_PATH "$1/lib/jexec" jexec 
        fi
        append_hl_group $JINFO_FILE_PATH $full_path_file $file
    fi
    if array_contains JDKHL_ARRAY $file; then
        append_jdkhl_group $(create_jinfo_file "${NAME}") $full_path_file $file
    fi
    if array_contains JDK_ARRAY $file; then
        append_jdk_group $(create_jinfo_file "${NAME}") $full_path_file $file
    fi
    #echo $file
    #echo "Register Alternatives for $file"
    if [ "$2" == "inactive" ]; then
        : 
        else
        update_alternatives $file $full_path_file $PRIORITY_TO_ASSIGN 
    fi
done

# unset variables
unset ALTERNATIVE_DIR
unset NAME 
