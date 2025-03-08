### Summary: Include screen shots or a video of your app highlighting its features
This is a demo recipes app. The main features are:

1. Displays a list of recipes downloaded from the web
2. Allows the user to pin recipes as favorites
3. Alllows the user to navigate to the web page for a particular recipe
4. The favorites are persisted to disk via User Defaults

### Focus Areas: What specific areas of the project did you prioritize? Why did you choose to focus on these areas?
- General polish and user friendliness, since this is something that I'm very passionate about
- SwiftUI component reusability to avoid repeating code and keep things nice and tidy
- Single source of truth to be able to easily share data between screens
- Thread safety for the source of truth

### Time Spent: Approximately how long did you spend working on this project? How did you allocate your time?
I spent around 8 hours total working on the project. I took about 1 hour to plan the general architecture of the app and the rest was development and research time. While working on this I was able to do a deep dive into modern concurrency concept like actors which was a great learning experience.

### Trade-offs and Decisions: Did you make any significant trade-offs in your approach?
For data updates in the view models, I'm doing a full wipe and replace when the repository notifies of changes. This helps keep the UI always in sync with the data model but it could result in performance hits as the size of the data grows. These updates could be more granular but for the purposes of this exercise, I kept it simple.

### Weakest Part of the Project: What do you think is the weakest part of your project?
The unit tests, specifically the ones that interact with reactive combine code can be flaky and I'm sure this can be made much more reliable.

### Additional Information: Is there anything else we should know? Feel free to share any insights or constraints you encountered.
