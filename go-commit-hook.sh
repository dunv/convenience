#!/usr/bin/env bash

# heavily inspired by multiple other sources

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NORMAL=$(tput sgr0)
LIME_YELLOW=$(tput setaf 190)

STAGED_GO_FILES=$(git diff --cached --name-only | grep ".go$")

if [[ "$STAGED_GO_FILES" = "" ]]; then
  printf "${GREEN}No go files staged ${NORMAL}Continuing to commit.\n"
  exit 0
fi

GOLANGCI_LINT=$(which golangci-lint)

# Check for golangci-lint
if [[ ! -x "$GOLANGCI_LINT" ]]; then
  printf "\t\033[41mPlease install golangci-lint (go get -u github.com/golangci/golangci-lint/cmd/golangci-lint)"
  exit 1
fi

printf "${LIME_YELLOW}Running golangci-lint on all staged *.go files...${NORMAL}\n"

OLD=$(pwd)
cd $(git rev-parse --show-toplevel)/src

golangci-lint run 
if [[ $? != 0 ]]; then
  printf "${RED}Linting failed! ${NORMAL}Please fix errors before committing.\n"
  exit 1
else
 printf "${GREEN}Linting passed! ${NORMAL}Continuing to commit.\n"
fi

# Run tests
printf "${LIME_YELLOW}Running tests...${NORMAL}\n"
CI=true go test -v ./... -failfast -p 1 -count 1
if [[ $? != 0 ]]; then
  printf "${RED}Tests failed! ${NORMAL}Please fix errors before committing.\n"
  exit 1
else
 printf "${GREEN}Tests passed! ${NORMAL}Continuing to commit.\n"
fi

cd $OLD

