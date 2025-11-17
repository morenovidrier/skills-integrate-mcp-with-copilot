#!/bin/bash
#
# Script to post a closing comment to Issue #5
# 
# Usage: ./post-closing-comment.sh
# Requires: GH_TOKEN or GITHUB_TOKEN environment variable

set -e

OWNER="morenovidrier"
REPO="skills-integrate-mcp-with-copilot"
ISSUE_NUMBER=5
COMMENT_BODY="The admin mode authentication system has been successfully implemented, allowing teachers to manage student registrations while students can view activities. Thank you to everyone for your ideas and feedback on this enhancement!"

# Check for authentication
if [ -z "$GH_TOKEN" ] && [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GH_TOKEN or GITHUB_TOKEN environment variable must be set"
    echo ""
    echo "Please set one of these variables with a GitHub personal access token"
    echo "that has 'repo' scope permissions."
    echo ""
    echo "Example:"
    echo "  export GH_TOKEN='your_token_here'"
    echo "  ./post-closing-comment.sh"
    exit 1
fi

# Use GH_TOKEN if set, otherwise use GITHUB_TOKEN
TOKEN="${GH_TOKEN:-$GITHUB_TOKEN}"

# Post comment using GitHub CLI if available
if command -v gh &> /dev/null; then
    echo "Using GitHub CLI to post comment..."
    export GH_TOKEN="$TOKEN"
    if gh issue comment "$ISSUE_NUMBER" \
        --repo "$OWNER/$REPO" \
        --body "$COMMENT_BODY"; then
        echo "✓ Successfully posted closing comment to issue #$ISSUE_NUMBER"
        exit 0
    else
        echo "Failed to post comment using gh CLI"
        exit 1
    fi
else
    # Fallback to curl if gh is not available
    echo "GitHub CLI not found, using curl..."
    
    API_URL="https://api.github.com/repos/$OWNER/$REPO/issues/$ISSUE_NUMBER/comments"
    
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL" \
        -H "Authorization: token $TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Content-Type: application/json" \
        -d "{\"body\": $(echo "$COMMENT_BODY" | jq -Rs .)}")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | sed '$d')
    
    if [ "$HTTP_CODE" = "201" ]; then
        echo "✓ Successfully posted closing comment to issue #$ISSUE_NUMBER"
        echo "$BODY" | jq -r '.html_url'
        exit 0
    else
        echo "Failed to post comment. HTTP status: $HTTP_CODE"
        echo "$BODY"
        exit 1
    fi
fi
