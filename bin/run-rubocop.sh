#!/bin/bash
if [ "${CIRCLE_BRANCH}" != "master" ]; then
    warn=$(git diff -z --name-only origin/master \
           | xargs -0 bundle exec rubocop-select \
           | xargs --no-run-if-empty bundle exec rubocop)

    detected=$(echo "$warn" | grep "Offenses:")
    if [ -n "$detected" ]; then
        echo "$warn" \
        | bundle exec rubocop \
            --require rubocop/formatter/checkstyle_formatter \
            --format RuboCop::Formatter::CheckstyleFormatter \
        | bundle exec checkstyle_filter-git diff origin/master \
        | bundle exec saddler report \
            --require saddler/reporter/github \
            --reporter Saddler::Reporter::Github::PullRequestReviewComment
        exit 1
    fi
fi

exit 0
