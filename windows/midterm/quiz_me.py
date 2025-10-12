#!/usr/bin/env python3
"""
CST8342 Midterm Quiz Script
Randomly quizzes you on questions from the study guide.
Includes answer key based on most likely correct answers.

Usage:
    python quiz_me.py [options]
    
Options:
    -n, --num-questions N    Number of questions (default: 10)
    -f, --no-feedback        Don't show correct answers immediately
    -h, --help              Show this help message
"""

import random
import re
import sys
from pathlib import Path


# Answer key based on the question design
ANSWER_KEY = {
    1: 'C', 2: 'D', 3: 'A', 4: 'D', 5: 'A', 6: 'B', 7: 'C', 8: 'A', 9: 'C', 10: 'D',
    11: 'B', 12: 'B', 13: 'B', 14: 'B', 15: 'A', 16: 'A', 17: 'A', 18: 'A', 19: 'A', 20: 'A',
    21: 'B', 22: 'B', 23: 'C', 24: 'C', 25: 'A', 26: 'A', 27: 'C', 28: 'B', 29: 'A', 30: 'A',
    31: 'A', 32: 'A', 33: 'A', 34: 'B', 35: 'A', 36: 'A', 37: 'B', 38: 'B', 39: 'A', 40: 'A',
    41: 'A', 42: 'A', 43: 'A', 44: 'C', 45: 'A', 46: 'A', 47: 'A', 48: 'C', 49: 'D', 50: 'B',
    51: 'A', 52: 'B', 53: 'B', 54: 'C', 55: 'B', 56: 'B', 57: 'B', 58: 'A', 59: 'B', 60: 'A',
    61: 'B', 62: 'D', 63: 'B', 64: 'A', 65: 'B', 66: 'A', 67: 'A', 68: 'B', 69: 'A', 70: 'A',
    71: 'B', 72: 'A', 73: 'B', 74: 'A', 75: 'B', 76: 'B', 77: 'B', 78: 'A', 79: 'A', 80: 'A',
    81: 'A', 82: 'A', 83: 'A', 84: 'A', 85: 'A', 86: 'B', 87: 'B', 88: 'A', 89: 'A', 90: 'B',
    91: 'A', 92: 'A', 93: 'B', 94: 'A', 95: 'A', 96: 'A', 97: 'B', 98: 'A', 99: 'A', 100: 'A'
}


def parse_questions(file_path):
    """Parse the markdown file and extract questions with answers."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    questions = []
    # Match numbered questions with their options
    pattern = r'(\d+)\.\s+(.+?)\n\s+A\.\s+(.+?)\n\s+B\.\s+(.+?)\n\s+C\.\s+(.+?)\n\s+D\.\s+(.+?)(?=\n\n|\n\d+\.|\Z)'
    
    matches = re.findall(pattern, content, re.DOTALL)
    
    for match in matches:
        num, question, opt_a, opt_b, opt_c, opt_d = match
        questions.append({
            'number': int(num),
            'question': question.strip(),
            'options': {
                'A': opt_a.strip(),
                'B': opt_b.strip(),
                'C': opt_c.strip(),
                'D': opt_d.strip()
            }
        })
    
    return questions


def ask_question(q_data, show_answer=True, question_num=1):
    """Ask a single question and return if answer was correct."""
    print(f"\n{'='*70}")
    print(f"Question {question_num}: {q_data['question']}")
    print(f"{'='*70}")
    
    for letter in ['A', 'B', 'C', 'D']:
        print(f"   {letter}. {q_data['options'][letter]}")
    
    print()
    while True:
        answer = input("Your answer (A/B/C/D) or 'skip': ").strip().upper()
        if answer in ['A', 'B', 'C', 'D', 'SKIP']:
            break
        print("Please enter A, B, C, D, or 'skip'")
    
    if answer == 'SKIP':
        print("⏭️  Skipped!")
        return None, None
    
    correct_answer = ANSWER_KEY.get(q_data['number'])
    is_correct = answer == correct_answer
    
    if show_answer:
        if is_correct:
            print(f"✅ CORRECT! The answer is {correct_answer}")
        else:
            print(f"❌ INCORRECT! The correct answer is {correct_answer}")
            print(f"   {correct_answer}. {q_data['options'][correct_answer]}")
    else:
        print(f"✓ You selected: {answer}")
    
    return answer, is_correct


def main():
    """Main quiz function."""
    # Parse command-line arguments
    num_questions = None
    show_answers = True
    
    i = 1
    while i < len(sys.argv):
        arg = sys.argv[i]
        if arg in ['-h', '--help']:
            print(__doc__)
            return
        elif arg in ['-n', '--num-questions']:
            if i + 1 >= len(sys.argv):
                print("Error: -n/--num-questions requires a number")
                return
            try:
                num_questions = int(sys.argv[i + 1])
                i += 1
            except ValueError:
                print(f"Error: Invalid number '{sys.argv[i + 1]}'")
                return
        elif arg in ['-f', '--no-feedback']:
            show_answers = False
        else:
            print(f"Error: Unknown argument '{arg}'")
            print("Use -h or --help for usage information")
            return
        i += 1
    
    print("=" * 70)
    print("CST8342 MIDTERM QUIZ")
    print("=" * 70)
    
    # Find the questions file
    script_dir = Path(__file__).parent
    questions_file = script_dir / "CST8342_MidTermQuestions.md"
    
    if not questions_file.exists():
        print(f"Error: Could not find {questions_file}")
        return
    
    # Parse questions
    print("\nLoading questions...")
    questions = parse_questions(questions_file)
    print(f"Loaded {len(questions)} questions!")
    
    # Ask how many questions if not specified
    if num_questions is None:
        while True:
            try:
                user_input = input(f"\nHow many questions? (1-{len(questions)}, default: 10): ").strip()
                if not user_input:
                    num_questions = 10
                else:
                    num_questions = int(user_input)
                
                if 1 <= num_questions <= len(questions):
                    break
                print(f"Please enter a number between 1 and {len(questions)}")
            except ValueError:
                print("Please enter a valid number")
    else:
        # Validate command-line specified number
        if not (1 <= num_questions <= len(questions)):
            print(f"Error: Number of questions must be between 1 and {len(questions)}")
            return
    
    # Ask if they want instant feedback (if not specified via args)
    if '--no-feedback' not in sys.argv and '-f' not in sys.argv:
        feedback = input("\nShow correct answers immediately? (Y/n): ").strip().lower()
        show_answers = feedback != 'n'
    
    # Randomly select questions
    selected = random.sample(questions, num_questions)
    
    print(f"\n🎯 Starting quiz with {num_questions} questions!")
    print("=" * 70)
    
    results = []
    for i, q in enumerate(selected, 1):
        print(f"\n[Question {i} of {num_questions}]")
        answer, is_correct = ask_question(q, show_answers, question_num=i)
        if answer:
            results.append({
                'seq_number': i,
                'number': q['number'],
                'question': q['question'],
                'answer': answer,
                'correct': is_correct,
                'correct_answer': ANSWER_KEY.get(q['number'])
            })
    
    # Summary
    print("\n" + "=" * 70)
    print("QUIZ COMPLETE!")
    print("=" * 70)
    
    if results:
        correct_count = sum(1 for r in results if r['correct'])
        total = len(results)
        percentage = (correct_count / total * 100) if total > 0 else 0
        
        print(f"\nScore: {correct_count}/{total} ({percentage:.1f}%)")
        
        if not show_answers:
            print("\n📋 Answer Review:")
            for r in results:
                status = "✅" if r['correct'] else "❌"
                print(f"{status} Question {r['seq_number']}: You answered {r['answer']}, Correct answer: {r['correct_answer']}")
        
        # Performance feedback
        if percentage >= 90:
            print("\n🌟 Outstanding! You're well prepared!")
        elif percentage >= 75:
            print("\n👍 Great job! Keep reviewing!")
        elif percentage >= 60:
            print("\n📚 Good effort! Study the missed topics.")
        else:
            print("\n💪 Keep studying! Review your lab materials.")
    else:
        print(f"\nYou skipped all questions.")
    
    print("\n💡 Check your lab materials and lectures for more details!")
    print("\nGood luck on your midterm! 🍀")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\nQuiz interrupted. Good luck studying! 👋")
    except Exception as e:
        print(f"\nError: {e}")
