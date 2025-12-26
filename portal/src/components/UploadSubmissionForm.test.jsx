import React from 'react';
import { render, fireEvent, screen } from '@testing-library/react';
import UploadSubmissionForm from './UploadSubmissionForm';

describe('UploadSubmissionForm', () => {
  it('renders and submits valid JSON', async () => {
    const mockSubmit = jest.fn(() => Promise.resolve());
    render(<UploadSubmissionForm onSubmit={mockSubmit} />);
    const textarea = screen.getByLabelText(/paste json/i);
    fireEvent.change(textarea, { target: { value: '{"foo": "bar"}' } });
    fireEvent.click(screen.getByText(/submit/i));
    expect(await screen.findByText(/submission successful/i)).toBeInTheDocument();
    expect(mockSubmit).toHaveBeenCalledWith({ foo: 'bar' });
  });

  it('shows error for invalid JSON', () => {
    const mockSubmit = jest.fn();
    render(<UploadSubmissionForm onSubmit={mockSubmit} />);
    const textarea = screen.getByLabelText(/paste json/i);
    fireEvent.change(textarea, { target: { value: '{foo: bar}' } });
    fireEvent.click(screen.getByText(/submit/i));
    expect(screen.getByText(/invalid json/i)).toBeInTheDocument();
    expect(mockSubmit).not.toHaveBeenCalled();
  });
});
