using Documenter, Shovel

makedocs(sitename="Shovel")

mkpath("docs/build/images")
cp("docs/src/assets/Default Snowflake Circuit.PNG","docs/build/images/Default Snowflake Circuit.PNG")
cp("docs/src/assets/Latex Snowflake Circuit.PNG","docs/build/images/Latex Snowflake Circuit.PNG")
cp("docs/src/assets/stoping rule.pdf","docs/build/images/stoping rule.pdf")
