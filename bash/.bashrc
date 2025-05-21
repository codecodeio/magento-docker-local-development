#Terminal Prompt
parse_git_branch() {
  git branch 2>/dev/null | sed -n '/\* /s///p'
}
PS1='\[\033[0;32m\]$(if [ $? = 0 ]; then echo "√"; else echo "✗ $?"; fi)\[\033[0m\] \[\033[1;36m\]\w\[\033[0m\] \[\033[0;33m\]$(parse_git_branch)\[\033[0m\] \$ '

#Shell
alias refresh="source ~/.bashrc"
alias ll='ls -FGlAhp'

#Magento
alias mag='bin/magento'
alias magbuild='bin/magento setup:upgrade && bin/magento setup:di:compile && bin/magento cache:clean && bin/magento cache:flush'
alias magcc='bin/magento cache:clean && bin/magento cache:flush'
alias magsu='bin/magento setup:upgrade'
alias magsdc='bin/magento setup:di:compile'
alias magscd='bin/magento setup:static-content:deploy -f'
alias magdel='rm -rf var/cache var/page_cache var/view_preprocessed generated/code generated/metadata'
alias magrestart='composer install && magbuild && magscd'
alias magut='vendor/bin/phpunit'
alias magtest='magut app/code && magcs app/code && magcs app/design && magmd app/code && magmd app/design'
magcs() {
  vendor/bin/phpcs \
    --standard=dev/tests/static/framework/Magento/ruleset.xml \
    --colors \
    --exclude="Magento2Framework.Header.CopyrightAnotherExtensionsFiles,Magento2Framework.Header.Copyright,Magento2Framework.Header.CopyrightGraphQL,Magento2.Legacy.InstallUpgrade,Magento2.Less.PropertiesSorting,Magento.Less.PropertiesSorting,Magento2.Less.ColonSpacing,Magento.Html.HtmlBinding" \
    "$1" \
    && \
    vendor/bin/phpmd \
    "$1" \
    text \
    dev/tests/static/testsuite/Magento/Test/Php/_files/phpmd/ruleset.xml \
    --ignore-violations-on-exit
}
magcsf() {
  php vendor/bin/phpcbf \
    --standard=dev/tests/static/framework/Magento/ruleset.xml \
    --colors \
    --exclude="Magento2Framework.Header.CopyrightAnotherExtensionsFiles,Magento2Framework.Header.Copyright,Magento2Framework.Header.CopyrightGraphQL,Magento2.Legacy.InstallUpgrade,Magento2.Less.PropertiesSorting,Magento.Less.PropertiesSorting,Magento2.Less.ColonSpacing,Magento.Html.HtmlBinding" \
    "$1"
}
magmd() {
  vendor/bin/phpmd \
    "$1" \
    text \
    dev/tests/static/testsuite/Magento/Test/Php/_files/phpmd/ruleset.xml \
    --ignore-violations-on-exit
}