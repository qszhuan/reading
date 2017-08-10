cp _drafts/template.md _posts/
bookname=$1
authorname=$2

pushd _posts
sed -i '' 's/%bookname%/'$bookname'/g' template.md 
sed -i '' 's/%author%/'$authorname'/g' template.md 

date=`date "+%Y-%m-%d"`
mv template.md $date'-读《'$bookname'》.md'
popd
