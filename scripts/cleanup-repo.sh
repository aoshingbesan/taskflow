#!/bin/bash

# TaskFlow Repository Cleanup Script
# This script removes unnecessary files and directories from the repository

echo "🧹 Starting TaskFlow repository cleanup..."

# Remove Python cache files
echo "📦 Removing Python cache files..."
find . -type f -name "*.pyc" -delete
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true

# Remove virtual environment (if it exists in the repo)
echo "🐍 Removing virtual environment..."
rm -rf venv/ 2>/dev/null || true

# Remove OS generated files
echo "🖥️  Removing OS generated files..."
find . -name ".DS_Store" -delete
find . -name "Thumbs.db" -delete
find . -name "*.swp" -delete
find . -name "*.swo" -delete

# Remove temporary files
echo "🗑️  Removing temporary files..."
find . -name "*.tmp" -delete
find . -name "*.temp" -delete
find . -name "*.bak" -delete
find . -name "*.log" -delete

# Remove IDE files
echo "💻 Removing IDE files..."
rm -rf .vscode/ 2>/dev/null || true
rm -rf .idea/ 2>/dev/null || true
find . -name "*.iml" -delete

# Remove Terraform state files (keep configs)
echo "🏗️  Removing Terraform state files..."
rm -f terraform/*.tfstate* 2>/dev/null || true
rm -f terraform/.terraform/ 2>/dev/null || true

# Remove Azure deployment files (keep examples)
echo "☁️  Removing Azure deployment files..."
rm -f *.publishsettings 2>/dev/null || true
rm -f *.pubxml 2>/dev/null || true
rm -f test-azure-credentials.json 2>/dev/null || true

# Remove recovery documentation (keep for reference but don't commit)
echo "📋 Removing recovery documentation..."
rm -f RECOVERY_GUIDE.md 2>/dev/null || true
rm -f RECOVERY_SUMMARY.md 2>/dev/null || true
rm -f startup.txt 2>/dev/null || true

# Remove test coverage files
echo "📊 Removing test coverage files..."
rm -rf htmlcov/ 2>/dev/null || true
rm -f .coverage 2>/dev/null || true
rm -f coverage.xml 2>/dev/null || true

# Remove database files
echo "🗄️  Removing database files..."
find . -name "*.db" -delete
find . -name "*.sqlite" -delete
find . -name "*.sqlite3" -delete

# Remove backup files
echo "💾 Removing backup files..."
find . -name "*.backup" -delete
find . -name "*.old" -delete
find . -name "*.orig" -delete

# Remove empty directories
echo "📁 Removing empty directories..."
find . -type d -empty -delete 2>/dev/null || true

echo "✅ Repository cleanup completed!"
echo ""
echo "📋 Summary of what was removed:"
echo "   - Python cache files (*.pyc, __pycache__)"
echo "   - Virtual environment (venv/)"
echo "   - OS generated files (.DS_Store, Thumbs.db)"
echo "   - Temporary files (*.tmp, *.temp, *.bak, *.log)"
echo "   - IDE files (.vscode/, .idea/, *.iml)"
echo "   - Terraform state files (*.tfstate*)"
echo "   - Azure deployment files (*.publishsettings, *.pubxml)"
echo "   - Recovery documentation (RECOVERY_*.md, startup.txt)"
echo "   - Test coverage files (htmlcov/, .coverage)"
echo "   - Database files (*.db, *.sqlite*)"
echo "   - Backup files (*.backup, *.old, *.orig)"
echo "   - Empty directories"
echo ""
echo "🚀 Your repository is now clean and ready for submission!" 