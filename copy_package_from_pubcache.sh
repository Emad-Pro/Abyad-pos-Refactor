#!/bin/bash

# اسم الحزمة والإصدار (بدون علامات ^)
PACKAGE_NAME=$1
PACKAGE_VERSION=$2

# مجلد المشروع الحالي
PROJECT_DIR=$(pwd)

# مجلد الهدف داخل مشروعك
TARGET_DIR="$PROJECT_DIR/packages/$PACKAGE_NAME"

# المسار في pub-cache
PUB_CACHE="$HOME/.pub-cache/hosted/pub.dev"
SOURCE_DIR="$PUB_CACHE/$PACKAGE_NAME-$PACKAGE_VERSION"

# التحقق من وجود النسخة في pub-cache
if [ ! -d "$SOURCE_DIR" ]; then
  echo "❌ الحزمة $PACKAGE_NAME-$PACKAGE_VERSION غير موجودة في pub-cache"
  exit 1
fi

# إنشاء مجلد الحزم إذا غير موجود
mkdir -p "$PROJECT_DIR/packages"

# نسخ الحزمة
cp -r "$SOURCE_DIR" "$TARGET_DIR"

echo "✅ تم نسخ $PACKAGE_NAME-$PACKAGE_VERSION إلى packages/$PACKAGE_NAME"

# تعليمات للمستخدم
echo ""
echo "📌 الآن أضف هذا إلى pubspec.yaml:"
echo ""
echo "$PACKAGE_NAME:"
echo "  path: packages/$PACKAGE_NAME"
