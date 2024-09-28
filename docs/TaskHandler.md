:::mermaid
classDiagram
    note "last edited 12th sept 2024"
    TaskHandler o-- Task
    Node3D <|-- Unit
    Unit o-- TaskHandler
    Node <|-- Task
    class Task {
    Array args
    bool hasDelta
    Callable task
    void _init()
    }
    Node <|-- TaskHandler
    class TaskHandler {
        Task nextTask
        Array taskQueue
        Array args
        Callable currentTask
        bool hasDelta
        bool taskFinished
        void _int()
        Task pushTask()
        Task push()
        Task pop()
        Array pushMultipleTasks()
        bool callTask()
        bool isEmpty()
        void clearTaskQueue()
    }
:::

:::mermaid
flowchart
    A[currentTask is not null] -->|true| B[currentTask returns true];
    B -->|true| C;
    A -->|false| C[isEmpty returns true];
    B -->|false| D[hasDelta is true];
    D -->|true| E{{push delta into args}};
    D -->|false| F{{call currentTask with args}};
    E --> F;
    C -->|false| H{{set currentTask to null}};
    C -->|true| G{{pop next task from taskQueue into currentTask}};
    H --> F;
    F --> Z(( ));
    G --> Z;
    Z --> A;
:::