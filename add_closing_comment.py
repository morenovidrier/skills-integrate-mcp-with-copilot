#!/usr/bin/env python3
"""
Script to add a closing comment to GitHub Issue #5

This script adds a closing comment thanking contributors and describing
the implemented solution for the Admin Mode authentication feature.
"""

import os
import sys
import json
import urllib.request
import urllib.error

def add_comment_to_issue():
    """Add a closing comment to Issue #5"""
    
    # Repository information
    owner = "morenovidrier"
    repo = "skills-integrate-mcp-with-copilot"
    issue_number = 5
    
    # Comment text
    comment_body = (
        "The admin mode authentication system has been successfully implemented, "
        "allowing teachers to manage student registrations while students can view activities. "
        "Thank you to everyone for your ideas and feedback on this enhancement!"
    )
    
    # GitHub API endpoint
    url = f"https://api.github.com/repos/{owner}/{repo}/issues/{issue_number}/comments"
    
    # Try to get GitHub token from environment
    github_token = os.environ.get('GITHUB_TOKEN')
    
    if not github_token:
        print("Error: GITHUB_TOKEN environment variable not set")
        print("Please set GITHUB_TOKEN with a valid GitHub personal access token")
        sys.exit(1)
    
    # Prepare request
    data = json.dumps({"body": comment_body}).encode('utf-8')
    
    headers = {
        'Authorization': f'token {github_token}',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
        'User-Agent': 'GitHub-Copilot-Agent'
    }
    
    # Make API request
    try:
        req = urllib.request.Request(url, data=data, headers=headers, method='POST')
        with urllib.request.urlopen(req) as response:
            result = json.loads(response.read().decode('utf-8'))
            print(f"✓ Successfully added comment to issue #{issue_number}")
            print(f"  Comment ID: {result.get('id')}")
            print(f"  Comment URL: {result.get('html_url')}")
            return True
    except urllib.error.HTTPError as e:
        print(f"Error adding comment: {e.code} {e.reason}")
        print(f"Response: {e.read().decode('utf-8')}")
        return False
    except Exception as e:
        print(f"Unexpected error: {str(e)}")
        return False

if __name__ == "__main__":
    success = add_comment_to_issue()
    sys.exit(0 if success else 1)
