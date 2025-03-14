# Go Code Style

# Reasons and Goals

Why is all this necessary if we can already write code that works?

## Reasons for Creating This Document

As practice shows, a number of problems arise:

- Team members adhere to different code styles, and team composition can change. The codebase becomes harder to maintain and develop if the code differs stylistically.
- If there are no agreements on code review processes, this process drags on.
- When writing code, it takes more time to remember best practices.

## Goals We Want to Achieve

Maintaining and following this document can help achieve the following goals:

- Improving the quality of the product's codebase. Explicit discussion of various techniques will help the team synchronize, understand the nuances of these techniques, and keep the codebase cleaner.
- Accelerating the code review process. Controversial points will be discussed only once and recorded in this document. A single place with best practices is created and **maintained**.

## Why We Don't Use Third-Party Best Practices

Many different best practices can be found in open source, so why do we need to maintain our own?

There are various best practices available in the public domain: ["Uber Go Style Guide"](https://github.com/uber-go/guide/blob/master/style.md), ["Thanos Go Style Guide"](https://thanos.io/contributing/coding-style-guide.md/) and others. These sources describe practices well and explain the reasons for their use. We can be guided by them, but it will be more difficult to search for the right practice across different sources, and the team can supplement this list with their own practices. Some of our practices will be borrowed from these sources.

---

# Development Flow

### Commit Messages

Can be anything, as in our flow, commit descriptions are not significant. When possible, describe the changes made.

When you need to know why a change was made, a good description can help you remember.

## Code Reviews Agreements

Agreements need to be discussed.

- Only the participant who created a discussion can resolve it.
- The MR author is responsible for it: functionality, requesting reviews, deployment to all environments, including production.

---

# Go Code Style Guide

When reading such practices, simple cases are usually given as examples. In practice, everything is more complicated — our task as a development team is to figure out how to solve complicated cases.

## Working with SQL Queries

### In queries, we explicitly specify the schema name: schema.table

A single repository may have several different files that mention SQL queries. Moreover, these queries may relate to different schemas.

For transparency, we specify the schema explicitly. This also simplifies application configuration since there is no need to specify `search_path=schema_name`.

If it becomes necessary to move to a new schema (hypothetical case), schema names will need to be updated in each query.

We consider this bad:

```go
const selectFromTable = `SELECT * FROM table_name;`
```

We consider this good:

```go
const selectFromTable = `SELECT * FROM schema_name.table_name;`
```

## Tests Are Important

All practices extend to tests as well.

Good code is always covered with tests. When writing tests, we have confidence that the code does not contain errors in the tested examples. Tests are good documentation, so the cleanliness of tests should be given due attention.

When there is time for test coverage, it should be used. **It's better not to write tests with poor formatting**, as they complicate maintenance.

### Test Case Names

Example of a test block with a poor description:

```go
{
    name: "Test 1: negative path",
    args: args{
        password: "pwd",
    },
    wantErr: true,
}
```

When changing the tested function, tests will need to be modified. It will be harder to understand what exactly is being tested.

It's better to describe the test case explicitly in the name with an explanation of why the test should return such values:

```go
{
    name: "Return error if password is too short",
    args: args{
        password: "pwd",
    },
    wantErr: true,
}
```

### Size of Test Functions

Using the *table driven tests* approach, the file usually grows significantly:

```go
...
controller := gomock.NewController(t)
defer controller.Finish()

deletionConnection := connMock.NewMockConnection(controller)
deletionConnection.EXPECT().Exec(gomock.Any()).Return(nil, errors.New("deletion error")).AnyTimes()

vacuumConnection := connMock.NewMockConnection(controller)
vacuumConnection.EXPECT().Exec(gomock.Any()).Return(nil, errors.New("vacuum error")).AnyTimes()

tests := []struct {
    name    string
    fields  fields
    wantErr bool
}{
    {
        name: "Deletion error should be handled and returned",
        fields: fields{
            conn: deletionConnection,
        },
        wantErr: true,
    },
    {
        name: "Vacuum error should be handled and returned",
        fields: fields{
            conn: vacuumConnection,
        },
        wantErr: true,
    },
    ...
}
...
```

The test is harder to read because connection mocks are created at the test level. If you need to add several more tests with new mocks, the file will be even harder to read and **maintain**.

You can extract the creation of controllers, indicating this by the function name:

```go
...
controller := gomock.NewController(t)
defer controller.Finish()

tests := []struct {
    name    string
    fields  fields
    wantErr bool
}{
    {
        name: "Deletion error should be handled and returned",
        fields: fields{
            conn: simulateDeletionErrorOnConnection(controller),
        },
        wantErr: true,
    },
    {
        name: "Vacuum error should be handled and returned",
        fields: fields{
            conn: simulateVacuumErrorOnConnection(controller),
        },
        wantErr: true,
    },
    ...
}
...

func simulateDeletionErrorOnConnection(controller *gomock.Controller) conn.Connection {
    errToBeReturned := errors.New("deletion error")
    var nilErrToBeReturned error

    return simulateConnection(controller, errToBeReturned, nilErrToBeReturned)
}

func simulateVacuumErrorOnConnection(controller *gomock.Controller) conn.Connection {
    var nilErrToBeReturned error
    errToBeReturned := errors.New("vacuum error")

    return simulateConnection(controller, nilErrToBeReturned, errToBeReturned)
}
```

## Language Conventions

A good codebase is characterized by uniformity.

### new() versus &{}

The difference between `new()` and `&{}` is in the ability to get the address of a variable [with a default value for subsequent operations with it](https://softwareengineering.stackexchange.com/questions/210399/why-is-there-a-new-in-go).

We will use `&{}` instead of `new()` to use fewer functions (even though it's from `builtin`) in the code.

We consider this bad:

```go
user := new(User)
```

We consider this good:

```go
user := &User{}
```

### Error Handling

It's better to wrap errors so that you can trace the path they took. If errors are not wrapped anywhere, the logs will contain low-level errors, making it difficult to understand where the error occurred.

We consider this bad:

```go
if err := verify(user); err != nil {
        return err
}
```

We try not to use:

```go
import "github.com/pkg/errors"

if err := verify(user); err != nil {
        return errors.Wrap(err, "user verification")
}
```

We consider this good:

```go
if err := verify(user); err != nil {
        return fmt.Errorf("user verification: %w", err)
}
```

Reasons for using `fmt` instead of `github.com/pkg/errors`:

- We use only the standard library, avoiding external packages
- We delegate the responsibility for checking for typos in format writing to the linter. This point needs to be explicitly checked when configuring the linter.
- The ability to check an error of any nesting and its type using `.Is()`, `.As()` seems more comprehensive to us than `errors.Cause()`

### Error Naming

We use `err` as long as the error is used as boilerplate code (`if err != nil {}`).

If the error is needed for further processing, we add a prefix for semantic context:

```go
_, doErr := doSomething(tx)
if doErr != nil {
    if rollbackErr := tx.Rollback(ctx); rollbackErr != nil {
        return fmt.Errorf("%w: %v", doErr, rollbackErr)
    }

    return fmt.Errorf("do something: %w", doErr)
}
```

### Error Grouping

We group errors in one place if they are part of the public API.

If the error is private to a function, we place it next to the function that returns this error.

### Declaration of Types and Constants Together

We group type and constant declarations together to make the code visually easier to understand and read.

We consider this bad:
```go
type (
    DB     string
    Locale string
)

const (
    AmericanEnglish = Locale("en_US")
    Albanian        = Locale("sq")
)

const (
    UnitedStates = DB("us")
    Russia       = DB("ru")
)
```

We consider this good:
```go
type Locale string

const (
    AmericanEnglish = Locale("en_US")
    Albanian        = Locale("sq")
)

type DB string

const (
    UnitedStates = DB("us")
    Russia       = DB("ru")
)
```

### Configs

As long as we have a small number of configurable parameters, we will use environment variables.
We'll empirically define the number of parameters as 10, roughly estimated.

We use the `github.com/Netflix/go-env` library due to its simple API and ease of use.

```go
type Config struct {
    AppAddress     string `env:"APP_ADDRESS,required=true"`
    MetricsAddress string `env:"METRICS_ADDRESS,required=true"`

    ProjectsService struct {
        Address string `env:"PROJECTS_SERVICE_ADDRESS,required=true"`
        Token   string `env:"PROJECTS_SERVICE_TOKEN,required=true"`
    }
}
```

### Naming ENV Variables

Often you can find variables like `SOME_SERVICE_ADDRESS` where it's not clear from the name what should be put there.
We decide that we need to choose better names for ENV variables so that it's clear from the name what is inside and in what format.

For the specific case of URL naming, we use [URL naming](https://en.wikipedia.org/wiki/URL).

| Part Naming | Example |
| ------ | ------ |
| SCHEME | http |
| USERINFO | username:password |
| HOST | semrush.com |
| PORT | 80 |

For example:
- `SOME_SERVICE_SCHEME_USERINFO_HOST_PORT` = `http://username@semrush.com:80`
- `SOME_SERVICE_HOST_PORT` = `semrush.com:80`

### Import Aliases
Suppose we have two files:
```go
// file a.go
import a "example/of/pkg"

// file b.go
import b "example/of/pkg"
```
In this case, the imports are not consistent. In one file, the package `example/of/pkg` has the alias `a`, in the second -- `b`.
We want to achieve consistent imports so that the codebase is coherent.

Therefore, we try to import packages without using aliases, as in this case, the consistency of imports will be fulfilled by default.

If aliases cannot be avoided, we should use those that are already used in other places.

### Must*() func
For entities that are important for application startup, we use the must version of the constructor.
Since the application cannot work without these entities, for simplification, we will not check for errors when using the constructor, but immediately terminate.
Unlike a regular constructor, it will panic, for example, if the parameters are not valid:

```go
func New() (Something, error) {
    ...
}

func MustNew() Something {
    s, err := New()
    if err != nil {
        panic(err)
    }

    return s
}
```

### Casting Objects from One Context to Another
To cast objects from one context to another, we will use builders (not to be confused with the builder pattern).
By grouping build functions relative to one builder, we logically organize casts at the code level.

For example, to cast a user from a gRPC port to a user from use cases, you need to add the corresponding function to the builder:
```go
func (b paramsBuilder) buildUser(user *User) (types.User, error) {
    userType, err := b.userType(user)
    if err != nil {
        return types.User{}, fmt.Errorf("user type: %w", err)
    }

    userID := types.UserID(user.GetId())

    return types.User{
        ID:     userID,
        Type:   userType,
        APIKey: user.GetApiKey(),
        Email:  user.GetEmail(),
    }, nil
}
```

Builders are not responsible for validating incoming objects, but only map them to another type.
If an output object cannot be built from the input object, an error is returned.

### Constants

To write fewer symbols and be able to use iota, we choose this option:
```go
const (
    Mobile  Device = "mobile"
    Desktop Device = "desktop"
)
```

Instead of this:
```go
const (
    Mobile  = Device("mobile")
    Desktop = Device("desktop")
)
```

### Types app/types, app/commands, app/query

If the same type is needed in both commands and queries, then it belongs in `app/types` (until there is a need to separate them).

### Private and Public Structures. Default-friendly Behavior
If a structure is default-friendly, then it should be declared public.

Example of a default-friendly structure:
```go
type DefaultFriendlyStruct struct {
    something someInterface
}

func (s DefaultFriendlyStruct) Do() {
    if s.something != nil {
        s.something.MethodCall() // May not cause a panic
    }
}
```

Example of a non-default-friendly structure:
```go
type NotDefaultFriendlyStruct struct {
    something someInterface
}

func (s NotDefaultFriendlyStruct) Do() {
    s.something.MethodCall() // May cause a panic
}
```

If it's unsafe to use a structure, then it should be declared private and an interface should be returned through a constructor.

```go
type Doer interface {
    Do()
}

type notDefaultFriendlyStruct struct{
    something someInterface
}

func NewDoer(something interface{}) Doer {
    // arguments validation should be here
    
    return &notDefaultFriendlyStruct{
        something: something,
    }
}

func (s notDefaultFriendlyStruct) Do() {
    s.something.MethodCall() // Field is valid, thanks to the NewDoer constructor
}
```

### Constructors Create Structures Without Leaks
A constructor only initializes a structure without performing non-obvious actions: establishing connections, spawning goroutines, etc.

To establish a connection, there is the `gopkg/connection` package.

```go
type DoerConnection interface {
    Doer
    connection.Connection
}

type implementation struct{}

func NewDoerConnection() DoerConnection {
    // Only init implementation struct
    
    return &implementation{}
}

func (i implementation) Establish() error {
    // Establish connection here
    
    return nil
}

func (i implementation) Terminate() error {
    // Terminate connection here
    
    return nil
}
``` 