::: mermaid
classDiagram
    Node3d <|-- Unit
    Unit <|-- GroundUnit
    Node <|-- TaskHandler
    Unit o-- TaskHandler
    Unit o-- Weapon
    Weapon o-- Ammunition
    class Unit {
        NavigationAgent3D nav
        VehicleBody3D model
        VehicleWheel3D wheel
        Marker3D marker
        MeshInstance3D meshNode
        TaskHandler taskHandler
        float engineForce
        float engineForceReverse
        int rotationVelocity
        int team
        void setup()
        bool checkIfSelected()
        bool driveToTarget()
        bool rotateToTarget()
        bool rotateAndMove()
        bool setTarget()
        bool getReachablePosition()
    }
    class GroundUnit {
        _physics_process()
    }
    click TaskHandler href "./TaskHandler.md"
:::