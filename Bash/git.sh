#!/bin/bash

echo "# reports" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/nhashley21/reports.git
git push -u origin main

git config --global user.email "nicholas.ashley82.com"
git config --global user.name "nhashley21"
