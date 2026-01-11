#!/bin/sh
set -e

echo "🔨 Building Slidev presentations..."

mkdir -p dist

# ✅ Фикс: используем временный файл вместо массива
TEMP_JSON="/tmp/presentations.tmp"
echo "[" > "$TEMP_JSON"

FIRST=1
for file in slides/*.md; do
  [ -f "$file" ] || continue
  name=$(basename "$file" .md)
  
  # Заголовок из первого # 
  title=$(grep -m1 "^# " "$file" 2>/dev/null | sed 's/^# *//' || echo "$name")
  
  if [ $FIRST -eq 0 ]; then
    echo "," >> "$TEMP_JSON"
  fi
  FIRST=0
  
  cat >> "$TEMP_JSON" << EOF
  {
    "id": "$name",
    "title": "$title",
    "path": "/$name/index.html"
  }
EOF
done

echo "]" >> "$TEMP_JSON"
mv "$TEMP_JSON" dist/presentations.json

echo "✅ presentations.json created ($(grep -c '"id"' dist/presentations.json || echo 0) items)"

# Билдим каждую презентацию
count=0
for file in slides/*.md; do
  [ -f "$file" ] || continue
  name=$(basename "$file" .md)
  echo "Building $name..."
  
  bunx slidev build "$file" \
    --out "../dist/$name" \
    --base "/$name/"    
  count=$((count + 1))
done

echo "✅ Built $count presentations"

# Копируем главную страницу
cp index-template.html dist/index.html

echo "🎉 Build complete!"
