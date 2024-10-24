:::mermaid
flowchart
    A[MainMenu] -->|SINGLEPLAYER| B[SingleplayerMenu];
    A -->|MULTIPLAYER| C[MultiplayerMenu];
    A -->|SETTINGS| D[Settings];
    A -->|EXIT| E((quit game));
    B -->|BACK| A;
    C -->|BACK| A;
    D -->|BACK| A;
    B -->|SKIRMISH| F[SkirmishMenu];
    B -->|CAMPAIGN| G[Campaign];
    B -->|ARMORY| H[Armory];
    C -->|HOST| F;
    C -->|JOIN| F;
    F -->|GO| I{{MAPNAME}};
    G --> J[NOT YET IMPLEMENTED];
    H --> J;
    I -->|ESCAPE_KEY| K[PauseMenu];
    K -->|CONTINUE| I;
    K -->|SETTINGS| L[Settings];
    L -->|BACK| K;
    K -->|MAIN MENU| A;
    K -->|QUIT TO DESKTOP| E
:::