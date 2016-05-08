#! /bin/sh

_wrap() {
	echo "---
title: $1
---

\`\`\`
$2
\`\`\`
"

}


for FILE in $(ls docs); do
	FILE=${FILE%.md}
	git checkout master -- doc/${FILE}.txt > /dev/null 2>&1
	if [ "$?" = 0 ]; then
		echo "sync ${FILE} ..."
		_wrap $FILE "$(cat doc/${FILE}.txt)" > docs/${FILE}.md
	fi
done

rm -rf doc
