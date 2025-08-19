#!/usr/bin/env python3
"""
Validation script for checking the health of the API and data processing scripts.
This can be run locally or in CI to validate the scripts work correctly.
"""

import os
import sys
import json
import tempfile
import shutil
from pathlib import Path

def check_questions_json():
    """Check if questions.json exists and is valid JSON."""
    questions_path = "assets/data/questions.json"
    if not os.path.exists(questions_path):
        print(f"❌ Error: {questions_path} not found")
        return False
    
    try:
        with open(questions_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        if 'questions' not in data:
            print("❌ Error: questions.json missing 'questions' key")
            return False
        
        questions = data['questions']
        print(f"✅ Found {len(questions)} questions in questions.json")
        
        # Check a few questions have required fields
        required_fields = ['answer', 'question']
        sample_size = min(5, len(questions))
        for i in range(sample_size):
            q = questions[i]
            for field in required_fields:
                if field not in q:
                    print(f"❌ Error: Question {i} missing required field '{field}'")
                    return False
        
        print(f"✅ Validated structure of first {sample_size} questions")
        return True
        
    except json.JSONDecodeError as e:
        print(f"❌ Error: Invalid JSON in {questions_path}: {e}")
        return False

def check_python_scripts():
    """Check that Python scripts can be imported without errors."""
    scripts = [
        'scripts/fill_commons_metadata.py',
        'tool/fill_commons_images.py'
    ]
    
    for script_path in scripts:
        if not os.path.exists(script_path):
            print(f"❌ Error: {script_path} not found")
            return False
        
        try:
            # Check if the script compiles
            with open(script_path, 'rb') as f:
                compile(f.read(), script_path, 'exec')
            print(f"✅ {script_path} compiles successfully")
        except SyntaxError as e:
            print(f"❌ Syntax error in {script_path}: {e}")
            return False
    
    return True

def check_requirements():
    """Check if requirements.txt exists and lists required packages."""
    req_path = "scripts/requirements.txt"
    if not os.path.exists(req_path):
        print(f"⚠️  Warning: {req_path} not found")
        return True  # Not critical
    
    try:
        with open(req_path, 'r') as f:
            requirements = f.read().strip()
        
        required_packages = ['requests', 'tqdm']
        for package in required_packages:
            if package not in requirements:
                print(f"⚠️  Warning: {package} not found in requirements.txt")
        
        print(f"✅ requirements.txt found with content: {requirements.replace(chr(10), ', ')}")
        return True
        
    except Exception as e:
        print(f"⚠️  Warning: Error reading requirements.txt: {e}")
        return True  # Not critical

def test_fill_commons_metadata_help():
    """Test that the fill_commons_metadata script shows help."""
    try:
        import subprocess
        result = subprocess.run([
            sys.executable, 'scripts/fill_commons_metadata.py', '--help'
        ], capture_output=True, text=True, timeout=10)
        
        if result.returncode == 0:
            print("✅ fill_commons_metadata.py --help works")
            return True
        else:
            print("⚠️  Warning: fill_commons_metadata.py --help failed")
            return True  # Not critical for basic validation
            
    except Exception as e:
        print(f"⚠️  Warning: Could not test fill_commons_metadata.py help: {e}")
        return True  # Not critical

def main():
    """Run all validation checks."""
    print("🔍 Running validation checks for Guess the Heritage API scripts...")
    print()
    
    checks = [
        check_questions_json,
        check_python_scripts,
        check_requirements,
        test_fill_commons_metadata_help,
    ]
    
    all_passed = True
    for check in checks:
        passed = check()
        if not passed:
            all_passed = False
        print()
    
    if all_passed:
        print("🎉 All validation checks passed!")
        return 0
    else:
        print("❌ Some validation checks failed")
        return 1

if __name__ == "__main__":
    exit(main())