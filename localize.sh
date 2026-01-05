#!/usr/bin/env bash

XLIFF_PATH=./tmp/xcode-xliff-export

# Sample commands to import an XLIFF file:
#
# ./localize.sh xliff
# swift run ../MergeTranslations/MergeTranslationsCLI \
#  --localization fr \
#  --xliffDir "tmp/xcode-xliff-export/" \
#  --extraMemoryXliffFile "/Users/daniel/Downloads/Timing-5/DateRangePickerEN.xliff/frx.xliff" \
#  --projectPath "../DateRangePicker" \
#  --skip "DateRangePickerDemo" \
#  --out "./tmp/"

function export_xliff {
  xcodebuild -exportLocalizations \
      -project DateRangePicker.xcodeproj \
      -localizationPath $XLIFF_PATH \
      -exportLanguage en \
      -exportLanguage de \
      -exportLanguage es \
      -exportLanguage fr \
      -exportLanguage zh-Hans
}

function find_strings {
  # Exclude framework and Xliff output directories
  find . \
    -type d \( -path ./tmp -o -path ./Frameworks -o -path ./Pods \) -prune \
    -o -name \*.strings -print
}

function import_result {
  if [ $# -eq 0 ]
  then
    print_help
    exit 1
  fi

  rsync -av --prune-empty-dirs --include '*/' --include '*.strings' --exclude '*' "$1/" "."
}

function print_help {
  echo -e "Usage:\t$0 [command [options ...]]"
  echo ""
  echo "Commands:"
  echo -e "  strings\t\tList all .strings files in the project."
  echo -e "  xliff\t\t\tExport Xliff for all localizations to ${XLIFF_PATH}"
  echo -e "  import source_dir\tImports all .strings from source_dir, preserving directory structures"
}

# No command provided
if [ $# -eq 0 ]
then
  print_help
  exit 1
fi

# Execute each command
case "$1"
in
"strings")
  find_strings
  ;;
"xliff")
  export_xliff
  ;;
"import")
  shift
  import_result $@
  ;;

"-h")
  ;& # fallthrough
"--help")
  ;& # fallthrough
"help")
  ;& # fallthrough
*)
  print_help
  ;;
esac
