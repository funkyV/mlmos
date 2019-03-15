#!/bin/bash

awk -F ',' '{printf("%s", "HOST: " $1"\n")
            printf("%s", "IP: " $2"\n")
            printf("%s", "WEB: " $3"\n")
            printf("%s", "Backend: " $4"\n")
            printf("%s", "DB: " $5"\n\n")}' info.csv