#!/bin/sh
set -e

echo "🔨 Building Slidev presentations..."

mkdir -p dist

# Генерируем presentations.json
presentations=()
for file in slides/*.md; do
  [ -f "$file" ] || continue
  name=$(basename "$file" .md)
  title=$(grep -m1 "^# " "$file" 2>/dev/null | sed 's/^# *//' || echo "$name")
  
  presentations="$presentations{\"id\":\"$name\",\"title\":\"$title\",\"path\":\"/$name/index.html\"},"
done

# JSON
cat > dist/presentations.json << EOF
[${presentations%,}]
EOF

# Билдим каждую презентацию
for file in slides/*.md; do
  [ -f "$file" ] || continue
  name=$(basename "$file" .md)
  echo "Building $name..."
  npx slidev build "$file" --out "dist/$name" --base "/$name/"
done

echo "✅ Built $(find dist -name 'index.html' -not -path 'dist/index.html' | wc -l) presentations"
