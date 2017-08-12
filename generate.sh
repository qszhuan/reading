cp _drafts/template.md _posts/
bookname=$1
authorname=$2

pushd _posts
sed -i '' "s/%bookname%/$bookname/g" template.md 
sed -i '' "s/%author%/$authorname/g" template.md 

date=`date "+%Y-%m-%d"`
newName=$date'-读《'$bookname'》.md'
echo newName
mv template.md "$newName"
popd
