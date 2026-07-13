using UnityEngine;

[RequireComponent(typeof(CharacterController))]
public class FirstPersonController : MonoBehaviour
{
    [Header("Movement")]
    public float walkSpeed = 3.0f;
    public float runSpeed = 6.0f;
    public float jumpHeight = 1.2f;
    public float gravity = -9.81f;

    [Header("Look")]
    public float mouseSensitivity = 2.0f;
    public float lookXLimit = 85.0f;

    [Header("Head Bob")]
    public bool enableHeadBob = true;
    public float bobFrequency = 1.5f;
    public float bobHorizontalAmplitude = 0.05f;
    public float bobVerticalAmplitude = 0.075f;

    private Camera playerCamera;
    private CharacterController characterController;
    private Vector3 moveDirection;
    private float rotationX = 0f;
    private float rotationY = 0f;
    private float bobTimer = 0f;
    private Vector3 cameraInitialLocalPos;

    void Start()
    {
        characterController = GetComponent<CharacterController>();

        // Create or find camera
        if (Camera.main != null)
        {
            playerCamera = Camera.main;
        }
        else
        {
            GameObject camObj = new GameObject("PlayerCamera");
            playerCamera = camObj.AddComponent<Camera>();
            playerCamera.tag = "MainCamera";
        }

        playerCamera.transform.SetParent(transform, false);
        playerCamera.transform.localPosition = new Vector3(0, 0.8f, 0);
        cameraInitialLocalPos = playerCamera.transform.localPosition;

        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
    }

    void Update()
    {
        HandleLook();
        HandleMovement();
        HandleHeadBob();

        if (Input.GetKeyDown(KeyCode.Escape))
        {
            Cursor.lockState = CursorLockMode.None;
            Cursor.visible = true;
        }
        if (Input.GetMouseButtonDown(0) && Cursor.visible)
        {
            Cursor.lockState = CursorLockMode.Locked;
            Cursor.visible = false;
        }
    }

    void HandleLook()
    {
        float mouseX = Input.GetAxis("Mouse X") * mouseSensitivity;
        float mouseY = Input.GetAxis("Mouse Y") * mouseSensitivity;

        rotationX -= mouseY;
        rotationX = Mathf.Clamp(rotationX, -lookXLimit, lookXLimit);

        rotationY += mouseX;

        playerCamera.transform.localRotation = Quaternion.Euler(rotationX, 0f, 0f);
        transform.rotation = Quaternion.Euler(0f, rotationY, 0f);
    }

    void HandleMovement()
    {
        float speed = Input.GetKey(KeyCode.LeftShift) ? runSpeed : walkSpeed;

        float moveForward = Input.GetAxis("Vertical");
        float moveRight = Input.GetAxis("Horizontal");

        Vector3 forward = transform.TransformDirection(Vector3.forward);
        Vector3 right = transform.TransformDirection(Vector3.right);

        Vector3 horizontalMove = (forward * moveForward + right * moveRight).normalized * speed;

        if (characterController.isGrounded)
        {
            moveDirection = new Vector3(horizontalMove.x, 0f, horizontalMove.z);

            if (Input.GetButtonDown("Jump"))
            {
                moveDirection.y = Mathf.Sqrt(jumpHeight * -2f * gravity);
            }
        }
        else
        {
            moveDirection.x = horizontalMove.x;
            moveDirection.z = horizontalMove.z;
        }

        moveDirection.y += gravity * Time.deltaTime;
        characterController.Move(moveDirection * Time.deltaTime);
    }

    void HandleHeadBob()
    {
        if (!enableHeadBob || !characterController.isGrounded)
        {
            playerCamera.transform.localPosition = Vector3.Lerp(
                playerCamera.transform.localPosition,
                cameraInitialLocalPos,
                Time.deltaTime * 10f
            );
            bobTimer = 0f;
            return;
        }

        float inputMagnitude = new Vector2(Input.GetAxis("Horizontal"), Input.GetAxis("Vertical")).magnitude;
        if (inputMagnitude > 0.1f)
        {
            float speedMultiplier = Input.GetKey(KeyCode.LeftShift) ? 1.5f : 1.0f;
            bobTimer += Time.deltaTime * bobFrequency * speedMultiplier;

            float bobX = Mathf.Cos(bobTimer) * bobHorizontalAmplitude;
            float bobY = Mathf.Sin(bobTimer * 2f) * bobVerticalAmplitude;

            Vector3 bobOffset = new Vector3(bobX, bobY, 0f);
            playerCamera.transform.localPosition = cameraInitialLocalPos + bobOffset;
        }
        else
        {
            playerCamera.transform.localPosition = Vector3.Lerp(
                playerCamera.transform.localPosition,
                cameraInitialLocalPos,
                Time.deltaTime * 10f
            );
            bobTimer = 0f;
        }
    }
}
