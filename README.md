I built this to help myself learn for a particular exam where I was heavily time constrained and wanted to be as effective as possible in my learning. The resulting process and skills surpassed my expectations and it kind of saddens me that I only figured this process out on my second to last exam of my masters, so I wanted to share this with others, in case this helps them too. The code stuff is in rough shape and the most important part is really only the 

# Getting started

I use Claude and Claude code for this. Claude and its models just appeal more to me in its style and output for learning technical concepts, and claude code is just my preferred llm coding harness. You can use other LLMs, but your mileage may vary.

## Transcribe the lectures

I run the code inside the transcriber folder in a claude code session, together with its inbuilt Chrome MCP. Open chrome, navigate to the lectures moodle page where the videos are hosted, and then tell claude code to download their audio and transcribe it. You really kind of need claude code for this, since each lecturer uses a different style of uploading and hosting videos apperently, with different backing plugins and players, so its easiest to just let claude code play around in the browser to find the exact sources, request and system to download them, as standalone yt-dlp often was not sufficient for me.

For transcription just use a locally installed whisper, you can easily get any kind of whisper model and run it locally nowadays. If you only have meager CPU (Are you ok ? how are you holding up, you probably suffer having to train some of the models for our courses on a CPU, my condolences) maybe just run a small or medum model. If you have a Apple Silicon (M1-M5) machine or a GPU, use medium to large. Apple silicon is faster with whisper-mlx, but claude code will likely do the install and setup for you anyways, just follow its lead.

## Summarize the lectures

Once you have the transcriptions, set up a Project in the Claude Chat (Desktop App or Web). Not a cowork Project, just a normal project for talking to it. 

Then you add the skills from the skill folder (you can figure that out, just google it if you cant).

### Skills

The skills are meant to get a repeatable process for the steps involved in summarizing and learning the lectures. I based the skills on some academic research on learning and memory, they use chunked active recall and spaced repetition, and the skills are designed to help you do that.

**Knowledge Doc Builder**: This will take in a lecture material of any kind, and produce a structured knowledge document from it, that you can then save to your projects memory. Usually this is only a single document, like a PDF or Powerpoints (convert that to PDF first) from lecture. After you have added all the knowledge docs, i like to run the same skill, with the lecture transcripts, as they are not as large and the skill can cross-reference and check if it missed any important information, that was maybe only mentioned live in the lecture, like hints for the exam, tips or other information not the on slides.

**Course Mapper**: This is suppused to be run once you knowledge base in the project is complete. It will create a map of the course, structure the topics into clusters, rank them by importance, highlight important parts, common mistakes, distractors, and exam topics. You should use this map as a reference and plan for the actual learning.

**Active Recall Tutor**: This will teach you a cluster, piece by piece, stopping frequently and only teaching small chunks at a time. It will then ask you questions meant for you to repeat what you just learned from memory. It will then give you feedback on those answers, correct them or ask you to restate them again for recall. It will also often put focus on exam important facts, traps lecturers often mention, or common mistakes and distractors in multiple choice questions. It is also guided to try to interweave information from other clusters, do a cold recall from a previous cluster and at the end of a cluster, will ask you to restate the core facts from the cluster from memory. Afterwards it will prompt you for a round of multiple choice questions.

**MCQ Exam Simulator**: This will run you through a mock exam with multiple choice questions. Per default it will use only a single correct answer and 3 distractors, but you can obviously guide it to change that setup. You can either uses this standalone for a cluster or topic, or most often, you will use this after having completed a cluster with the active recall tutor, to test you knowledge

**Cheatsheet Builder**: If your exam permits, you are a cheeky fella or you just like this as an additional learning method, you can use this skill to create a cheat sheet for a cluster or topic, condensing the most important information, traps and formulas.

### Process

My process is the following:

1. Transcribe the lectures into text documents, using the transciber code and claude code.
2. Create a Claude Chat project. Add the skills if this is your first time.
3. Download all the lecture materials and slides, convert them to PDF and run them through the knowledge builder skill. Add the produced documents to the project.
4. Run a comparison of the produced knowledge against the lecture transcripts, update document if need be.
5. In the same conversation, run the course mapper skill. I like to do this in the same convo, even tho its not a fresh context, it can reference direct conversation and information from the lecturer itself, to guide ranking and material intensity.
6. You are set! Now i like to start with the first cluster, for this start of conversation like

```
/active-recall-tutor Lets do cluster 1. Use the course map.
```

I have started augmenting this a bit, since I am a dummy and need to be reminded of a lot of essentials and learned assumptions.

```
/active-recall-tutor Lets do cluster H. Use the course map.

Some notes: When introducing new variables or concepts not yet covered, on first occurency explain them. 

Use the course map to infer what is covered or not, we went in order of the clusters, i.e. A - G are already done (even if not all in your memory that updates only sporadically)
```

7. Do the active recall lecturing. After a chunk it will ask you questions about it. Dont cheat and look up, you will only lie to yourself. Embrace uncertainty or not knowing, state things as best as you can, as that will make its feedback and retried recall much more informative and useful. You will remember your mistake and combine that with the correct answer and that strengthens you memory.
8. After cluster completion and the recall from memory about everything, either the tutor will immediately start a round of multiple choice question or ask you. If not, ask it to do so.
9. Done. You can now repeat this process for all clusters, and feel confident in your knowledge.