# Its the gogo function. $1=branch on github, $2=local branch. (rebases and merges and pushes one branch at a time all the way to master). # If no $2 then pull --rebase performed on $1.
function gogo() {
	rbmpo $1 $2
}

# Called by gogo()
function rbmpo() {
	[ -z "$1" ] && gogo $(getBranchName) && return
	[ -z "$2" ] && echo rbmpo på $1 && rbplmpo $1 && return
	rbpo $1 $2
	mpo $1
}

# $1=branch on github (rebasepulls and pushes RB-branch)
function rbplmpo() {
	go $1
	mpo $1
}

function go() {
	[ -z "$1" ] && go $(getBranchName)
	git pull --rebase origin $1
	git push origin $1
}

# $1=starting branch on git hub. (merges and pushes one branch at a time all the way to master)
function mpo() {
	if test "$1" == "vnext/master" ; then 
		echo Klart!
		return
	fi
	key=$(getRBKey $1)
	nextVersion=$(getNextVersion $key)

	[ -z "$nextVersion" ] && echo Version för $key fanns ej && return

	echo -e mergarochpushar "$1" $nextVersion
	m $nextVersion $1 
	git push origin $nextVersion 
	mpo $nextVersion
}

# $1=branch on github, $2=local branch. (rebases and pushes)
function rbpo() {
	rb $1 $2
	git push origin $1
}

# Rebase branch $1 to branch $2 and then back again. 
function rb() {
	git checkout $1
	git pull --ff-only
	git rebase $1 $2
	git rebase $2 $1
}

function getBranchName()
{
   branch_name=$(git symbolic-ref -q HEAD)
   branch_name=${branch_name##refs/heads/}
   branch_name=${branch_name:-HEAD}
   echo $branch_name
}

# Returns next stratsys version given key (ex: RB51=>RB-5.2)
getNextVersion(){
value=$(arrayGet nextVersion $1)
echo -e $value
}

# Initializes table for version mapping. Needs to be updated when new branches.
declare "nextVersion_RB51=RB-5.2"
declare "nextVersion_RB52=5.3/master"
declare "nextVersion_53master=5.4/master"
declare "nextVersion_54master=5.5/master"
declare "nextVersion_55master=dev/master"
declare "nextVersion_devmaster=vnext/master"

# Used for associative array lookup.
arrayGet() { 
    local array=$1 index=$2
    local i="${array}_$index"
    echo -e "${!i}"
}

# Special letters used by stratsys versions can not be used as variable names (ex: RB-5.1/wee=>RB51wee)
getRBKey(){
echo "$1" | sed 's/-//' | sed 's/\.//' | sed 's/\///'
}

# Merges two branches. $1=Merge into, $2=Merge from
function m() {
echo -e mergar lite mellan $1 och $2
git checkout $1 && git pull --ff-only && git merge $2
}