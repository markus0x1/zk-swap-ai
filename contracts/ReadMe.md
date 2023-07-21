## Deploy to tenderly 

Run
```bash
forge script script/Deploy.s.sol:Deploy --fork-url tenderly --broadcast --slow
```

## Deploy to localhost 

Run
```bash
anvil
```

and in a separate window run
```bash
forge script script/Deploy.s.sol:Deploy --fork-url http://localhost:8545 --broadcast
```

