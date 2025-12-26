import React, { useState } from 'react';

/**
 * UploadSubmissionForm - allows users to upload a JSON file or submit JSON via a form for Gen3 submission.
 * SRP: Handles only upload/submission logic, delegates validation and API to parent.
 */
export default function UploadSubmissionForm({ onSubmit }) {
  const [jsonText, setJsonText] = useState('');
  const [fileError, setFileError] = useState('');
  const [status, setStatus] = useState('');

  const handleFileChange = (e) => {
    const file = e.target.files[0];
    if (!file) return;
    if (!file.name.endsWith('.json')) {
      setFileError('Please select a JSON file.');
      return;
    }
    const reader = new FileReader();
    reader.onload = (event) => {
      setJsonText(event.target.result);
      setFileError('');
    };
    reader.readAsText(file);
  };

  const handleChange = (e) => {
    setJsonText(e.target.value);
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    try {
      const json = JSON.parse(jsonText);
      setStatus('Submitting...');
      onSubmit(json)
        .then(() => setStatus('Submission successful!'))
        .catch((err) => setStatus('Submission failed: ' + err.message));
    } catch (err) {
      setStatus('Invalid JSON: ' + err.message);
    }
  };

  return (
    <form onSubmit={handleSubmit} style={{ maxWidth: 600, margin: '2em auto', padding: 20, border: '1px solid #ccc', borderRadius: 8 }}>
      <h2>Upload Submission JSON</h2>
      <div style={{ marginBottom: 12 }}>
        <label>Upload JSON file: </label>
        <input type="file" accept="application/json" onChange={handleFileChange} />
        {fileError && <div style={{ color: 'red' }}>{fileError}</div>}
      </div>
      <div style={{ marginBottom: 12 }}>
        <label>Or paste JSON here:</label>
        <textarea value={jsonText} onChange={handleChange} rows={8} style={{ width: '100%' }} />
      </div>
      <button type="submit">Submit</button>
      {status && <div style={{ marginTop: 10 }}>{status}</div>}
    </form>
  );
}
