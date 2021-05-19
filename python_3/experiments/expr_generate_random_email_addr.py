# -*- coding: utf-8 -*-
"""
Created on Sun Feb 21 09:02:51 2021
Objective: To generate a random list of email addresses and write to file
Reference: https://codereview.stackexchange.com/questions/58269/generating-random-email-addresses
@author: Ashish
"""
import random, string

domains = ["hotmail.com", "gmail.com", "aol.com", "mail.com", "mail.kz", "yahoo.com"]
letters = string.ascii_lowercase[:12]


def get_random_domain(domains):
    return random.choice(domains)


def get_random_name(letters, length):
    return "".join(random.choice(letters) for i in range(length))


def generate_random_emails(nb, length):
    return [
        get_random_name(letters, length) + "@" + get_random_domain(domains)
        for i in range(nb)
    ]


def main():
    # 7 refers to the number of chars in username part of the email id
    # 100 referes to the number of email address required
    print(generate_random_emails(100, 7))


if __name__ == "__main__":
    main()
