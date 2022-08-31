# Logo-extractor

This project is a web logo extractor based purely on HTML parsing and semantics analysis, it is construed by that structure :
 
  Back : An API is written in Haskell that is responsible to fetch the website address, parsing it, analyzing/applying a semantic-based heuristic, and finally returning an array of possible web logos candidates.
  
  Front : Just a console-based application written in Python that validates the URL and asks the back for the result, finally it writes everything on a CSV file.
 
 
 # Install
 
For the backend you only needs the stack package manager, you can get it at [here](https://docs.haskellstack.org/en/stable/install_and_upgrade/).
And after that you have to run these commands :

```
stack run myproj
```

If you prefer you can use the built version by :

```
stack build
stack exec myprok-exe
```

The front needs Python3 installed and the poetry package manager :
To run it is very easy just run this command:

```
poetry run python front/main.py
```

For now, we do not have the nix environment, but I can work with it this week (The problem is I did this project using an M1 chip that is not well supported by the nix yet, but I will try in another machine).

# The problem

At first glance, the problem does not seem so hard to solve with good precision but that is not the truth.
Extracting the urls and looking "hotwords" it not precise enought to get at least 30% (no source, just guessing here) of correct results.

![example](https://i.ibb.co/8rpy7X2/Screen-Shot-2022-08-30-at-21-09-27.png)

Both of the best ways of interpreting a logo are very human-mind oriented, I mean there is always the possibility of using an IA model, and I believe we can almost get it right using it, but first I do not have enough data to that and it is a very complex implementation, such that may be out of the scope for this home-task. 

So, I limited the project to search for HTML semantics characteristics, what I do here is to apply a heuristic that resembles genetic algorithms, so points (fitness) our accumulated, and they are shared by neighbors depending on HTML position.

# Limitations

There are two crucial limitations, first is the algorithm can not detect SVG-based logos (as defined by SVG HTML tag), and the second is there is no searching for .css file, so a logo that is defined on CSS background-URL for example can not be analyzed. This is crucial because most of the time we do not have a guess because of the two major problems. 
I decided not to implement it because it will probably take extra time for this work, the first is not so much because the parser is already adapted to recognize HTML tags context, but the second problem needs besides the context HTML analysis, it also needs a full search for the CSS files.

So, I decided not to delay more this work, but we can discuss further implementations if that is really a problem.
