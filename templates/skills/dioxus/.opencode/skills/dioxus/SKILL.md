---
name: dioxus
description: Dioxus 0.7 best practices and project conventions
---

# Dioxus 0.7

## Pages used to build this skill

### Building User Interfaces
- https://dioxuslabs.com/learn/0.7/essentials/ui/
- https://dioxuslabs.com/learn/0.7/essentials/ui/rsx/
- https://dioxuslabs.com/learn/0.7/essentials/ui/elements/
- https://dioxuslabs.com/learn/0.7/essentials/ui/attributes/
- https://dioxuslabs.com/learn/0.7/essentials/ui/conditional/
- https://dioxuslabs.com/learn/0.7/essentials/ui/iteration/
- https://dioxuslabs.com/learn/0.7/essentials/ui/components/
- https://dioxuslabs.com/learn/0.7/essentials/ui/render/
- https://dioxuslabs.com/learn/0.7/essentials/ui/assets/
- https://dioxuslabs.com/learn/0.7/essentials/ui/styling/
- https://dioxuslabs.com/learn/0.7/essentials/ui/hotreload/
- https://dioxuslabs.com/learn/0.7/essentials/ui/escape/

### The Basics of State
- https://dioxuslabs.com/learn/0.7/essentials/basics/reactivity/
- https://dioxuslabs.com/learn/0.7/essentials/basics/hooks/
- https://dioxuslabs.com/learn/0.7/essentials/basics/signals/
- https://dioxuslabs.com/learn/0.7/essentials/basics/event_handlers/
- https://dioxuslabs.com/learn/0.7/essentials/basics/async/
- https://dioxuslabs.com/learn/0.7/essentials/basics/resources/
- https://dioxuslabs.com/learn/0.7/essentials/basics/effects/
- https://dioxuslabs.com/learn/0.7/essentials/basics/hoisting/
- https://dioxuslabs.com/learn/0.7/essentials/basics/context/
- https://dioxuslabs.com/learn/0.7/essentials/basics/collections/
- https://dioxuslabs.com/learn/0.7/essentials/basics/error_handling/
- https://dioxuslabs.com/learn/0.7/essentials/basics/suspense/

### Routing
- https://dioxuslabs.com/learn/0.7/essentials/router/routes/
- https://dioxuslabs.com/learn/0.7/essentials/router/navigation/
- https://dioxuslabs.com/learn/0.7/essentials/router/layouts/

## Summary

Dioxus 0.7 is a cross-platform Rust UI framework that renders HTML/CSS on the web, desktop and mobile. The main patterns an AI assistant should follow are:

- Build UI with the `rsx!` macro using standard HTML elements and CSS.
- Make components pure functions of state that return `Element`.
- Store mutable state in `Signal`s, derive values with `use_memo`, and run side effects with `use_effect`.
- Fetch data with `use_resource` or `use_loader`, and run one-off async work with `spawn`/`use_action`.
- Keep data flow one-way: state lives in parents and is passed down through props or context; child components mutate state via callbacks, not by writing to props.
- Use `asset!` for static files and `document::Stylesheet` for CSS.
- Use the typed router (`Routable`) for in-app navigation, `Link` for links, and `Outlet` for layouts.

## Components and RSX

- Use `rsx! { ... }` to declare UI. It returns an `Element` (`Result<VNode, RenderError>`).
- Reference HTML elements directly: `div`, `input`, `button`, `svg`, etc.
- Embed Rust values in text with `"{value}"` or as full expressions in braces `{value}`.
- Use inline `if`/`else` and `for` loops inside `rsx!` for conditional and list rendering.

```rust
rsx! {
    h1 { "Hello, {name}" }
    if logged_in() {
        "Welcome back"
    } else {
        button { onclick: move |_| log_in(), "Log in" }
    }
    ul {
        for user in users.iter() {
            li { key: "{user.id}", "{user.name}" }
        }
    }
}
```

- Mark reusable components with `#[component]`. Their names must start with a capital letter or contain an underscore.
- Component props must implement `PartialEq` and `Clone`. Return `Element`.
- Use components in RSX; do **not** call them as plain functions.

```rust
#[component]
fn UserCard(name: String, active: bool) -> Element {
    rsx! {
        div {
            class: if active { "card active" } else { "card" },
            "{name}"
        }
    }
}
```

- For complex props, extract into a struct:

```rust
#[derive(Props, Clone, PartialEq)]
struct CardProps {
    title: String,
    #[props(default)]
    active: bool,
}

#[component]
fn Card(props: CardProps) -> Element { ... }
```

- Use `children: Element` to accept child elements.
- Use `ReadSignal<T>` / `ReadOnlySignal<T>` for reactive props so `Signal`, `Memo` and plain values all work.
- Spread props with `..some_props`.
- Add event handlers as props with `EventHandler<T>` or `Callback<I, O>`.

## State Management

- Local component state lives in hooks. `use_signal(|| initial)` is the workhorse.

```rust
let mut count = use_signal(|| 0);

rsx! {
    button { onclick: move |_| count += 1, "Count: {count}" }
}
```

- Read signals with `.read()`, `.cloned()` or call syntax `count()`. Write with `.write()` or `.set()`.
- Signals implement `Copy`; move them into closures and async blocks freely.
- Reading a signal inside a component or effect subscribes that scope to future changes.
- Writes are batched automatically; `await` acts as a step boundary.
- Do **not** hold `.read()` or `.write()` guards across `.await` points.

```rust
// good
onclick: move |_| {
    let next = count() + 1;
    count.set(next);
}
```

- Use `ReadSignal<T>` in component arguments for values that should stay reactive.
- Avoid passing a writable `Signal` as a prop so children can mutate it. Instead, pass a callback.

```rust
// bad
#[component]
fn Incrementer(mut sig: Signal<i32>) -> Element {
    rsx! { button { onclick: move |_| sig += 1, "+" } }
}

// good
#[component]
fn Incrementer(onclick: EventHandler<MouseEvent>) -> Element {
    rsx! { button { onclick, "+" } }
}
```

- Hoist shared state to the nearest common ancestor and pass signals/callbacks down.
- For deeply shared state, use `use_context_provider` and `use_context`. Wrap the data in a custom type to disambiguate by `TypeId`.
- Make context reactive by storing `Signal`s inside the context struct.

```rust
#[derive(Clone, Copy)]
struct Theme {
    color: Signal<String>,
}

fn App() -> Element {
    use_context_provider(|| Theme {
        color: Signal::new("blue".into()),
    });
    ...
}
```

- Use `GlobalSignal` / `GlobalMemo` for app-wide state. They are scoped per app instance, not process-wide.
- For fine-grained reactivity on structs or collections, use `use_store` and derive `Store`. This lets you "zoom in" with lenses and avoids cloning large collections on every change.

```rust
#[derive(Store, Default)]
struct AppState {
    title: String,
    items: Vec<String>,
}

let state = use_store(|| AppState::default());
rsx! { "{state.title()}" }
```

## Effects and Async

- Derive synchronous values with `use_memo`. It only notifies dependents when the result changes (`PartialEq`).

```rust
let full_name = use_memo(move || format!("{} {}", first(), last()));
```

- Run side effects with `use_effect`. Effects run after the UI is painted. Any signal read inside becomes a dependency.
- Prefer actions (event handlers / `use_action`) over effects when the work is triggered by user input.
- Use `peek()` to read a signal without subscribing.

```rust
use_effect(move || {
    let title = page_title();
    window().document().set_title(&title);
});
```

- Run futures with `spawn` or by returning an async closure from an event handler.
- Use `use_action` when you want to cancel previous invocations and expose `.value()`.

```rust
let mut fetch = use_action(move |id| async move {
    reqwest::get(format!("/api/items/{id}"))
        .await?
        .json::<Item>()
        .await
});

rsx! {
    button { onclick: move |_| fetch.call(current_id()), "Load" }
    match fetch.value() {
        Some(Ok(item)) => rsx! { "{item.name}" },
        Some(Err(_)) => rsx! { "Failed" },
        None => rsx! { "..." },
    }
}
```

- Futures are cancelled when their component unmounts. Keep them alive with `spawn_forever` (use sparingly).
- Ensure futures are cancel-safe; clean up resources with `Drop` guards if needed.
- Never block the main thread. Offload heavy CPU work to `std::thread` or web workers.

- Derive async state with `use_resource`. It restarts automatically when tracked signals inside the closure change.

```rust
let dogs = use_resource(move || async move {
    reqwest::get(format!("https://dog.ceo/api/breed/{breed}/images"))
        .await?
        .json::<BreedResponse>()
        .await
});
```

- For fullstack/client-server work that returns `Result`, prefer `use_loader` and propagate with `?`.
- Avoid request waterfalls: start all independent `use_resource`/`use_loader` calls before returning early.

## Styling and Assets

- Dioxus uses standard HTML/CSS. Style elements inline, per-element, or via stylesheets.
- Inline styles use either the `style` attribute or individual snake_case CSS properties.

```rust
rsx! {
    div {
        background_color: "blue",
        color: "white",
        padding: "20px",
        "styled"
    }
}
```

- Include stylesheets with `document::Stylesheet` and `asset!`:

```rust
static CSS: Asset = asset!("/assets/main.css");

rsx! {
    document::Stylesheet { href: CSS }
}
```

- Tailwind CSS works out of the box. Create `tailwind.css` at the project root:

```css
@import "tailwindcss";
@source "./src/**/*.{rs,html,css}";
```

Then include the generated output:

```rust
rsx! { document::Stylesheet { href: asset!("/assets/tailwind.css") } }
```

- Use multiple `class:` attributes for conditional Tailwind classes.
- Include static files with `asset!`. Paths are relative to the package root, not the filesystem.

```rust
static LOGO: Asset = asset!("/assets/logo.png");

rsx! { img { src: "{LOGO}" } }
```

- Assets are processed by the Dioxus CLI, hashed for caching, and pruned if unused. Mark must-include assets with `#[used]`.
- Read bundled file contents at runtime with `dioxus::asset_resolver::read_asset_bytes`.
- Put unreferenced deploy files (e.g. `robots.txt`) in `/public`.

## Routing

- Define routes with a `Routable` enum:

```rust
#[derive(Routable, Clone)]
#[rustfmt::skip]
enum Route {
    #[route("/")]
    Home {},
    #[route("/user/:id")]
    User { id: usize },
    #[route("/blog/:..segments")]
    Blog { segments: Vec<String> },
    #[route("/search?:query&:sort")]
    Search { query: String, sort: String },
}
```

- Static segments are fixed, dynamic segments use `:name`, catch-all uses `:..name`.
- Query parameters use `?:name&:other`; hash fragments use `#:name`.
- Custom segment types implement `FromStr` + `Display`. Query types need `FromStr + Default`.
- Nest routes with `#[nest("/prefix")]` ... `#[end_nest]`.
- Use `Link { to: Route::Home {} }` instead of raw `<a>` tags for client-side navigation.
- Programmatic navigation uses `navigator()`:

```rust
let nav = navigator();
nav.push(Route::Home {});
nav.replace(Route::Settings {});
nav.go_back();
```

- Wrap routes in layouts with `#[layout(Wrapper)]` and render children with `Outlet::<Route> {}`.
- Layout components must accept props for dynamic segments in their scope.

```rust
#[derive(Routable, Clone)]
#[rustfmt::skip]
enum Route {
    #[layout(AppShell)]
        #[route("/")]
        Home {},
}

#[component]
fn AppShell() -> Element {
    rsx! {
        header { "My App" }
        Outlet::<Route> {}
        footer { "Footer" }
    }
}
```

## Performance

- Derive expensive values with `use_memo` so dependents only re-run when the result actually changes.

```rust
let mut query = use_signal(|| "".to_string());
let filtered = use_memo(move || {
    items.read().iter().filter(|i| i.contains(&query())).cloned().collect::<Vec<_>>()
});
```

- Use `ReadOnlySignal<T>` or `ReadSignal<T>` for props that only need to be read. This lets callers pass `Signal`, `Memo`, or plain values without forcing a re-render of the child on every parent update.

```rust
#[component]
fn Badge(label: ReadOnlySignal<String>) -> Element {
    rsx! { span { "{label}" } }
}
```

- Avoid cloning large collections on every signal change. Use `use_store` with `#[derive(Store)]` for fine-grained field-level reactivity.

```rust
#[derive(Store, Default)]
struct AppState {
    title: String,
    items: Vec<String>,
}

let state = use_store(|| AppState::default());
rsx! {
    input { value: "{state.title()}", oninput: move |e| state.title_mut().set(e.value()) }
    ul {
        for (id, item) in state.items().iter().enumerate() {
            li { key: "{id}", "{item}" }
        }
    }
}
```

- Start independent async resources together to avoid waterfalls.
- Keep components small and pure; lift state only when truly shared.

## Common patterns

- Controlled input: bind `value` to a signal and update it in `oninput`.

```rust
let mut text = use_signal(|| "".to_string());
rsx! {
    input {
        value: "{text}",
        oninput: move |e| text.set(e.value()),
    }
}
```

- Uncontrolled form: read values from `onsubmit`.

```rust
rsx! {
    form {
        onsubmit: move |e| {
            e.prevent_default();
            let values = e.values();
            // process values
        },
        input { name: "username" }
    }
}
```

- File input: read selected files with `evt.files()` and read contents asynchronously.

```rust
input {
    r#type: "file",
    multiple: true,
    onchange: move |e| async move {
        for file in e.files() {
            if let Ok(content) = file.read_string().await {
                files.write().push(content);
            }
        }
    },
}
```

- Stop event propagation and prevent default when needed:

```rust
button {
    onclick: move |e| {
        e.stop_propagation();
        e.prevent_default();
    },
}
```

- Error boundaries catch errors from components and event handlers:

```rust
rsx! {
    ErrorBoundary {
        handle_error: |_| rsx! { "Something went wrong" },
        RiskyComponent {}
    }
}
```

- Suspense boundary for async data:

```rust
rsx! {
    SuspenseBoundary {
        fallback: |_| rsx! { "Loading..." },
        DataView {}
    }
}
```

Inside `DataView`:

```rust
let data = use_resource(...).suspend()?;
```

- For fullstack, use `use_server_future` for serialized server-client async data.

- Combine `ErrorBoundary` and `SuspenseBoundary` so loading and error states are handled in one place:

```rust
rsx! {
    ErrorBoundary {
        handle_error: |error| rsx! {
            p { "Failed to load data: {error}" }
        },
        SuspenseBoundary {
            fallback: |_| rsx! { p { "Loading..." } },
            DataView {}
        }
    }
}
```

Inside `DataView`, suspend the resource and propagate errors with `?`:

```rust
#[component]
fn DataView() -> Element {
    let posts = use_resource(move || async move {
        reqwest::get("https://api.example.com/posts")
            .await?
            .json::<Vec<Post>>()
            .await
    });

    let posts = posts.suspend()?;

    rsx! {
        ul {
            for post in posts.iter().cloned() {
                li { key: "{post.id}", "{post.title}" }
            }
        }
    }
}
```

## Anti-patterns to avoid

Each anti-pattern below includes a short example of what *not* to do and the recommended alternative.

### Calling hooks inside conditionals, loops or closures

Hooks must be called in the same order on every render.

```rust
// bad
#[component]
fn Bad(enabled: bool) -> Element {
    if enabled {
        let state = use_signal(|| 0); // hook order changes
    }
    rsx! { "..." }
}

// good
#[component]
fn Good(enabled: bool) -> Element {
    let state = use_signal(|| 0);
    rsx! {
        if enabled {
            "{state}"
        }
    }
}
```

### Returning early before all hooks have run

```rust
// bad
#[component]
fn Bad(user: Option<User>) -> Element {
    if user.is_none() {
        return rsx! { "No user" };
    }
    let name = use_signal(|| user.unwrap().name.clone());
    rsx! { "{name}" }
}

// good
#[component]
fn Good(user: Option<User>) -> Element {
    let name = use_signal(|| user.as_ref().map(|u| u.name.clone()));
    match name() {
        Some(n) => rsx! { "{n}" },
        None => rsx! { "No user" },
    }
}
```

### Mutating signals while rendering

```rust
// bad
#[component]
fn Bad() -> Element {
    let mut count = use_signal(|| 0);
    count += 1; // mutation during render
    rsx! { "{count}" }
}

// good
#[component]
fn Good() -> Element {
    let mut count = use_signal(|| 0);
    rsx! {
        button { onclick: move |_| count += 1, "{count}" }
    }
}
```

### Passing writable `Signal` props down the tree

```rust
// bad
#[component]
fn Editor(mut value: Signal<String>) -> Element {
    rsx! { input { oninput: move |e| value.set(e.value()) } }
}

// good
#[component]
fn Editor(value: ReadOnlySignal<String>, on_change: EventHandler<String>) -> Element {
    rsx! { input { value: "{value}", oninput: move |e| on_change.call(e.value()) } }
}
```

### Using array indices as `key` in lists

```rust
// bad
for (idx, item) in items.iter().enumerate() {
    li { key: "{idx}", "{item}" }
}

// good
for item in items.iter() {
    li { key: "{item.id}", "{item.name}" }
}
```

### Holding `.read()` / `.write()` guards across `.await`

```rust
// bad
let mut items = items.write();
let more = fetch_more().await; // deadlock / panic risk
items.extend(more);

// good
{
    let mut items = items.write();
    items.extend(fetched.clone());
}
let more = fetch_more().await;
items.write().extend(more);
```

### Creating `Signal::new` values dynamically inside loops/lists

```rust
// bad
for item in items.iter() {
    let local = use_signal(|| item.clone()); // wrong
}

// good
// hoist state into the parent signal/map, or use a Store/HashMap keyed by id
let item_states = use_signal(|| HashMap::<u64, String>::new());
```

### Using `dangerous_inner_html` with untrusted input

```rust
// bad
rsx! { div { dangerous_inner_html: user_input } }

// good
// sanitize first (e.g., with ammonia) or render as text
rsx! { div { "{sanitized_or_plain_text}" } }
```

### Using `web-sys` or direct DOM access for cross-platform code

```rust
// bad (web only)
web_sys::window().unwrap().alert_with_message("hi");

// good
// use Dioxus APIs or platform-specific modules gated behind cfg
#[cfg(target_arch = "wasm32")]
fn web_only() {}
```

### Returning early before starting independent resource calls

```rust
// bad (waterfall)
let user = use_resource(get_user).suspend()?;
let posts = use_resource(get_posts).suspend()?;

// good (parallel)
let user = use_resource(get_user);
let posts = use_resource(get_posts);
// read them later or use a combined SuspenseBoundary
```

### Overusing `use_effect` for user-triggered work

```rust
// bad
let mut query = use_signal(|| "".to_string());
use_effect(move || {
    search_api(query());
});

// good
let mut query = use_signal(|| "".to_string());
let search = use_action(|q: String| async move { search_api(q).await });
rsx! {
    input { oninput: move |e| query.set(e.value()) }
    button { onclick: move |_| search.call(query()), "Search" }
}
```

### Fetching data in many scattered places

```rust
// bad
// every leaf component calls its own use_resource

// good
// hoist data fetching near the route/page level and pass derived signals down
let data = use_resource(load_page_data);
rsx! { Header { data: data.map(|d| d.header) } }
```
