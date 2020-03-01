#!/usr/bin/env bash

# Usage: ./export_template.sh <project name> <project folder>

HELP_TEXT="Usage: ./export_template.sh <project name> <project folder>"

_juce_template_copy_required_files() {(
    set -e -u
    cp -r "Source" "$JUCE_TEMPLATE_TARGET/Source"
    cp -r "Modules" "$JUCE_TEMPLATE_TARGET/Modules"
    cp -r "BinaryData" "$JUCE_TEMPLATE_TARGET/BinaryData"
    cp -r "Scripts" "$JUCE_TEMPLATE_TARGET/Scripts"

    cp -r ".gitignore" "$JUCE_TEMPLATE_TARGET/.gitignore"
    cp -r "LICENSE.txt" "$JUCE_TEMPLATE_TARGET/LICENSE.txt"
    cp -r "README.md" "$JUCE_TEMPLATE_TARGET/README.md"

    cp -r "template.jucer" "$JUCE_TEMPLATE_TARGET/$JUCE_TEMPLATE_NAME.jucer"

    # Replace "template" in *.jucer file and README
    # https://myshittycode.wordpress.com/2014/07/24/os-x-sed-extra-characters-at-the-end-of-l-command-error/
    sed -i \
        "" \
        "s/template/$JUCE_TEMPLATE_NAME/g" \
        "$JUCE_TEMPLATE_TARGET/$JUCE_TEMPLATE_NAME.jucer" \
        "$JUCE_TEMPLATE_TARGET/README.md"

    rm "$JUCE_TEMPLATE_TARGET/Scripts/export_template.sh"
)}

_juce_template_initialize_git_repo() {(
    set -e -u
    cd "$JUCE_TEMPLATE_TARGET"

    git init
    git remote add origin "git@github.com:dbcooperaudio/$JUCE_TEMPLATE_NAME.git"

    git submodule add --depth=1 https://github.com/WeAreROLI/JUCE.git Modules/juce
    git config submodule.Modules/juce.shallow "true"

    git submodule add git@github.com:dbcooperaudio/dbcooper.git Modules/dbcooper

    git add -A
    git commit -m "Initial commit"
    git push -u origin master
    git checkout -b develop
    git push -u origin develop
    git checkout -b alpha
    git push -u origin alpha
    git checkout master
)}

if [[ "$#" -ne 2 || -z "$1" || -z "$2" ]]; then
    echo $HELP_TEXT
    exit 1
fi

export JUCE_TEMPLATE_NAME="$1"
export JUCE_TEMPLATE_TARGET="$2"

if ! mkdir $JUCE_TEMPLATE_TARGET; then
    exit 1
fi

echo "Copying over files..."
if ! _juce_template_copy_required_files > /dev/null; then
    echo "Aborting template export"
    rm -rf $JUCE_TEMPLATE_TARGET
    exit 1
fi

# TODO (Tony 02/29/20): If the repository doesn't exist on Github's side the git
#                       commands don't actually give a failure error code, so
#                       you may still see "Success" at the end but will need to
#                       go create the repo in Github then manually re-push the
#                       branches from the local repository.
echo "Initializing and pushing repo..."
echo "git@github.com:dbcooperaudio/$JUCE_TEMPLATE_NAME.git"
if ! _juce_template_initialize_git_repo > /dev/null; then
    echo "Aborting template export"
    rm -rf $JUCE_TEMPLATE_TARGET
    exit 1
fi

echo "Success!"
