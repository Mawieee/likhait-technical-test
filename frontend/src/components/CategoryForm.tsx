import React, { useState } from "react";
import { TextField, Button } from "../vibes";

interface CategoryFormProps {
  onSubmit: (name: string) => Promise<void>;
  onCancel?: () => void;
}

/**
 * Purpose: Renders a form to enter details for a new category and handles submission.
 *
 * @param props - Component props containing:
 *   - onSubmit (Function): Callback invoked when the form is submitted with a valid category name.
 *   - onCancel (Function, optional): Callback invoked when the user cancels the form.
 * @returns React element representing the category creation form.
 *
 * Side Effects: Manages local state for category name, validation errors, and submission status.
 *
 * Example:
 *   <CategoryForm onSubmit={handleAddCategory} onCancel={() => setIsOpen(false)} />
 */
export function CategoryForm({ onSubmit, onCancel }: CategoryFormProps) {
  const [name, setName] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim()) {
      setError("Category name is required");
      return;
    }
    setIsSubmitting(true);
    setError(null);
    try {
      await onSubmit(name.trim());
      setName("");
    } catch (err: any) {
      setError(err.message || "Failed to create category");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form
      onSubmit={handleSubmit}
      style={{ display: "flex", flexDirection: "column", gap: "1rem" }}
    >
      <TextField
        label="Category Name"
        type="text"
        placeholder="Enter category name"
        value={name}
        onChange={(e) => {
          setName(e.target.value);
          setError(null);
        }}
        error={error || undefined}
        fullWidth
        required
      />

      <div style={{ display: "flex", gap: "0.5rem", marginTop: "0.5rem" }}>
        <Button
          type="submit"
          variant="primary"
          disabled={isSubmitting}
          fullWidth
        >
          {isSubmitting ? "Submitting..." : "Add Category"}
        </Button>
        {onCancel && (
          <Button
            type="button"
            variant="secondary"
            onClick={onCancel}
            disabled={isSubmitting}
          >
            Cancel
          </Button>
        )}
      </div>
    </form>
  );
}
