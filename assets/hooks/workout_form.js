const STORAGE_KEY = "workout_form_state";

const WorkoutForm = {
    mounted() {
        // Try to restore form state on mount
        const stored = localStorage.getItem(STORAGE_KEY);
        if (stored) {
            const data = JSON.parse(stored);
            this.pushEvent("restore_form", data);
        }

        // Listen for form changes to save to localStorage
        this.handleEvent("persist_form", (data) => {
            localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
        });
    }
}

export default WorkoutForm